local os = require('os')
local zeebo_bundler = require('src/lib/cli/bundler')
local zeebo_builder = require('src/lib/cli/builder')
local zeebo_meta = require('src/lib/cli/meta')
local zeebo_fs = require('src/lib/cli/fs')

local function build(args)
    local bundler = ''
    local screen = args.screen
    local dist = args.dist

    local core_list = {
        repl={
            src='src/engine/core/repl/main.lua',
            post_exe='lua dist/main.lua'
        },
        love={
            src='src/engine/core/love/main.lua',
            post_exe='love dist -'..'-screen '..screen
        },
        ginga={
            src='src/engine/core/ginga/main.lua',
            post_exe='ginga dist/main.ncl -s '..screen,
            extras={
                'src/engine/core/ginga/main.ncl'
            }
        },
        native={
            src='src/engine/core/native/main.lua',
        },
        html5_webos={
            src='src/engine/core/native/main.lua',
            post_exe='webos24 $(pwd)/dist',
            pipeline={
                zeebo_meta.late(dist..'game.lua'):file(dist..'index.html'):file(dist..'appinfo.json'):pipe()
            },
            extras={
                'src/engine/meta/html5_webos/appinfo.json',
                'src/engine/core/html5/index.html',
                'src/engine/core/html5/index.html',
                'src/engine/core/html5/driver-wasmoon.js',
                'src/engine/core/html5/core-native-html5.js',
                'assets/icon80x80.png'
            }
        },
        html5_tizen={
            src='src/engine/core/native/main.lua',
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
                'src/engine/core/html5/core-native-html5.js',
                'assets/icon80x80.png'
            }
        },
        html5={
            src='src/engine/core/native/main.lua',
            pipeline={
                zeebo_meta.late(dist..'game.lua'):file(dist..'index.html'):pipe()
            },
            extras={
                'src/engine/core/html5/index.html',
                'src/engine/core/html5/driver-wasmoon.js',
                'src/engine/core/html5/core-native-html5.js'
            }
        },
        nintendo_wii={
            src='src/engine/core/nintendo_wii/main.lua',
            pipeline={
                zeebo_meta.late(dist..'game.lua'):file(dist..'meta.xml'):pipe()
            },
            extras={
                'assets/icon128x48.png',
                'src/engine/meta/nintendo_wii/meta.xml'
            }
        }
    }

    -- clean dist
    zeebo_fs.clear(args.dist)

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
        zeebo_fs.move(args.game, dist..'game.lua')
    end

    -- core move
    local index = 1
    local core = core_list[args.core]
    zeebo_builder.build(core.src, dist..bundler)
    if core.extras then
        while index <= #core.extras do
            local file = core.extras[index]
            zeebo_fs.move(file, dist..file:gsub('.*/', ''))
            index = index + 1
        end
    end

    -- combine files
    if #bundler > 0 then
        zeebo_bundler.build(dist..bundler, 'main.lua', dist..'main.lua')
        zeebo_fs.clear(dist..bundler)
        os.remove(dist..bundler)
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