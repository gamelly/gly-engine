local os = require('os')
local zeebo_module = require('src/lib/common/module')
local zeebo_bundler = require('src/lib/cli/bundler')
local zeebo_builder = require('src/lib/cli/builder')
local zeebo_assets = require('src/lib/cli/assets')
local zeebo_meta = require('src/lib/cli/meta')
local zeebo_fs = require('src/lib/cli/fs')
local util_fs = require('src/lib/util/fs')

local function build(args)
    local bundler = ''
    local screen = args.screen
    local dist = util_fs.path(args.dist).get_unix_path()

    local core_list = {
        none = {

        },
        repl={
            src='src/engine/core/repl',
            post_exe='lua dist/main.lua'
        },
        love={
            src='src/engine/core/love',
            post_exe='love dist -'..'-screen '..screen
        },
        ginga={
            src='ee/engine/core/ginga',
            post_exe='ginga dist/main.ncl -s '..screen,
            extras={
                'ee/engine/meta/ginga/main.ncl'
            }
        },
        lite={
            src='src/engine/core/lite',
        },
        native={
            src='src/engine/core/native',
        },
        html5_webos={
            src='src/engine/core/native',
            post_exe='webos24 $(pwd)/dist',
            pipeline={
                zeebo_meta.late(dist..'game.lua'):file(dist..'index.html'):file(dist..'appinfo.json'):pipe()
            },
            extras={
                'src/engine/meta/html5_webos/appinfo.json',
                'src/engine/core/html5/index.html',
                'src/engine/core/html5/index.html',
                'src/engine/core/html5/driver-wasmoon.js',
                'src/engine/core/html5/core-media-html5.js',
                'src/engine/core/html5/core-native-html5.js',
                'assets/icon512x423.png',
                'assets/icon80x80.png'
            }
        },
        html5_tizen={
            src='src/engine/core/native',
            pipeline={
                zeebo_meta.late(dist..'game.lua'):file(dist..'index.html'):file(dist..'config.xml'):pipe(),
                function() os.execute('cd '..dist..';~/tizen-studio/tools/ide/bin/tizen.sh package -t wgt;true') end
            },
            extras={
                'src/engine/meta/html5_tizen/config.xml',
                'src/engine/meta/html5_tizen/.tproject',
                'src/engine/core/html5/index.html',
                'src/engine/core/html5/index.html',
                'src/engine/core/html5/driver-wasmoon.js',
                'src/engine/core/html5/core-media-html5.js',
                'src/engine/core/html5/core-native-html5.js',
                'assets/icon80x80.png'
            }
        },
        html5_lite={
            src='src/engine/core/lite',
            pipeline={
                zeebo_meta.late(dist..'game.lua'):file(dist..'index.html'):pipe()
            },
            extras={
                'src/engine/core/html5/index.html',
                'src/engine/core/html5/driver-wasmoon.js',
                'src/engine/core/html5/core-media-html5.js',
                'src/engine/core/html5/core-native-html5.js'
            }
        },
        html5={
            src='src/engine/core/native',
            pipeline={
                zeebo_meta.late(dist..'game.lua'):file(dist..'index.html'):pipe()
            },
            extras={
                'src/engine/core/html5/index.html',
                'src/engine/core/html5/driver-wasmoon.js',
                'src/engine/core/html5/core-media-html5.js',
                'src/engine/core/html5/core-native-html5.js'
            }
        }
    }

    -- must be pass a core or game
    if not args.core and not args.game then
        return false, 'usage: '..args[0]..' build [game] -'..'-core [core]'
    end

    -- default core
    if not args.core then
        args.core = 'html5'
    end

    -- clean dist
    zeebo_fs.clear(dist)

    -- license advice
    if args.core == 'ginga' and not args.enterprise then
        return false, 'please use flag -'..'-enterprise to use commercial modules'
    end

    -- check core
    if not core_list[args.core] then
        return false, 'this core cannot be build!'
    end

    -- force html5 to bundler
    if args.core:find('html5') then
        args.bundler = true
    end

    -- pre bundler
    if  args.bundler then
        bundler = '_bundler/'
        zeebo_fs.clear(dist..bundler)
    end

    -- move game
    if args.game then
        local game = util_fs.file(args.game)
        zeebo_builder.build(game.get_unix_path(), game.get_file(), dist..bundler, 'game.lua', 'game_')
    end

    -- core move
    local core = core_list[args.core]
    do
        local index = 1
        if core.src then
            zeebo_builder.build(core.src, 'main.lua', dist..bundler, 'main.lua', 'core_')
        end
        if core.extras then
            while index <= #core.extras do
                local file = core.extras[index]
                zeebo_fs.move(file, dist..file:gsub('.*/', ''))
                index = index + 1
            end
        end
    end

    -- combine files
    if #bundler > 0 then
        if core.src then
            zeebo_bundler.build(dist..bundler..'main.lua', dist..'main.lua')
        end
        if args.game then
            zeebo_bundler.build(dist..bundler..'game.lua', dist..'game.lua')
        end
        zeebo_fs.clear(dist..bundler)
        zeebo_fs.rmdir(dist..bundler)
    end

    -- post process
    if core.pipeline then
        local index = 1
        while index <= #core.pipeline do
            local eval = core.pipeline[index]
            while type(eval) == 'function' do
                eval = eval()
            end
            index = index + 1
        end
    end

    if args.game then
        local game = zeebo_module.loadgame(dist..'game.lua')
        zeebo_assets.build(game and game.assets or {}, dist)
    end

    if args.run then
        if not core.post_exe then
            return false, 'this core cannot be runned after build!'
        end
        return os.execute(core.post_exe)
    end

    return true
end

return {
    build = build
}