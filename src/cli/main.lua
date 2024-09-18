local os = require('os')
local zeebo_bundler = require('src/lib/cli/bundler')
local zeebo_args = require('src/lib/common/args')
local zeebo_meta = require('src/lib/cli/meta')
local zeebo_fs = require('src/lib/cli/fs')

--! @cond
local run = zeebo_args.has(arg, 'run')
local bundler = zeebo_args.has(arg, 'bundler')
local coverage = zeebo_args.has(arg, 'coverage')
local core = zeebo_args.get(arg, 'core', 'ginga')
local dist = zeebo_args.get(arg, 'dist', './dist/')
local screen = zeebo_args.get(arg, 'screen', '1280x720')
local command = zeebo_args.param(arg, {'core', 'screen', 'dist'}, 1, 'help')
local game = zeebo_args.param(arg, {'core', 'screen', 'dist'}, 2, '')

-- alias for game examples
if game and #game > 0 and game:sub(1, 1) == '@' then
    game = 'examples/'..game:sub(2)..'/game.lua'
end

local core_list = {
    repl={
        src='src/engine/core/repl/main.lua',
        exe='lua src/engine/core/repl/main.lua '..game,
        post_exe='lua dist/main.lua'
    },
    love={
        src='src/engine/core/love/main.lua',
        exe='love src/engine/core/love -'..'-screen '..screen..' '..game,
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
            zeebo_meta.late(game):file(dist..'index.html'):file(dist..'appinfo.json'):pipe()
        },
        extras={
            'src/engine/meta/html5_webos/appinfo.json',
            'src/engine/core/html5/index.html',
            'src/engine/core/html5/index.html',
            'src/engine/core/html5/engine.js',
            'assets/icon80x80.png'
        }
    },
    html5_tizen={
        src='src/engine/core/native/main.lua',
        pipeline={
            zeebo_meta.late(game):file(dist..'index.html'):file(dist..'config.xml'):pipe(),
            function() os.execute('cd '..dist..';~/tizen-studio/tools/ide/bin/tizen.sh package -t wgt;true') end
        },
        extras={
            'src/engine/meta/html5_tizen/config.xml',
            'src/engine/meta/html5_tizen/.tproject',
            'src/engine/core/html5/index.html',
            'src/engine/core/html5/index.html',
            'src/engine/core/html5/engine.js',
            'assets/icon80x80.png'
        }
    },
    html5_ginga={
        src='src/engine/core/native/main.lua',
        post_exe='ginga dist/main.ncl -s '..screen,
        pipeline={
            zeebo_meta.late(game):file(dist..'index.html'):pipe()
        },
        extras={
            'src/engine/meta/html5_ginga/main.ncl',
            'src/engine/core/html5/index.html',
            'src/engine/core/html5/index.html',
            'src/engine/core/html5/engine.js',
        }
    },
    html5={
        src='src/engine/core/native/main.lua',
        pipeline={
            zeebo_meta.late(game):file(dist..'index.html'):pipe()
        },
        extras={
            'src/engine/core/html5/index.html',
            'src/engine/core/html5/engine.js'
        }
    },
    nintendo_wii={
        src='src/engine/core/nintendo_wii/main.lua',
        pipeline={
            zeebo_meta.late(game):file(dist..'meta.xml'):pipe()
        },
        extras={
            'assets/icon128x48.png',
            'src/engine/meta/nintendo_wii/meta.xml'
        }
    }
}

if command == 'run' then
    if not zeebo_args.get(arg, 'core') then
        core = 'love'
    end
    if not core_list[core] or not core_list[core].exe then
        print('this core cannot be runned!')
        os.exit(1)
    end
    os.exit(os.execute(core_list[core].exe) and 0 or 1)
elseif command == 'clear' or command == 'clean' then
    zeebo_fs.clear(dist)
elseif command == 'meta' then
    if core == 'ginga' then
        core = '{{title}} {{version}}'
    end
    zeebo_meta.current(game):stdout(core):run()
elseif command == 'bundler' then
    local path, file = game:match("(.-)([^/\\]+)$")
    zeebo_bundler.build(path, file, dist..file)
elseif command == 'test-self' then
    coverage = coverage and '-lluacov' or ''
    local files = zeebo_fs.ls('./tests')
    local index = 1
    local ok = true
    while index <= #files do
        ok = ok and os.execute('lua '..coverage..' ./tests/'..files[index])
        index = index + 1
    end
    if #coverage > 0 then
        os.execute('luacov src')
        os.execute('tail -n '..tostring(#files + 5)..' luacov.report.out')
    end
    if not ok then
        os.exit(1)
    end
elseif command == 'build' then
    -- clean dist
    zeebo_fs.clear(dist)
    
    -- check core
    if not core_list[core] then
        print('this core cannot be build!')
        os.exit(1)
    end

    -- force html5 to bundler
    if core:find('html5') then
        bundler = true
    end
    
    -- pre bundler
    if bundler then
        bundler = '_bundler/'
        zeebo_fs.clear(dist..bundler)
    else
        bundler = ''
    end

    -- move game
    if game and #game > 0 then
        zeebo_fs.move(game, dist..'game.lua')
    end

    -- core move
    local index = 1
    local core = core_list[core]
    zeebo_fs.build(core.src, dist..bundler)
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

    if run then
        if not core.post_exe then
            print('this core cannot be runned after build!')
            os.exit(1)
        end
        os.exit(os.execute(core.post_exe) and 0 or 1)
    end
elseif command == "help" then
    local help_message = "Available commands:\n" ..
    "- run: Executes the specified core. If no core is specified, defaults to 'love'.\n" ..
    "- clear | clean: Clears the specified distribution directory.\n" ..
    "- meta: Displays metadata for the current game.\n" ..
    "- bundler: Builds the game using the bundler.\n" ..
    "- test-self: Runs tests located in the './tests' directory.\n" ..
    "- build: Builds the game and prepares it for distribution.\n" ..
    "\n" ..
    "Available cores:\n" ..
    "- repl: Runs the REPL core.\n" ..
    "- love: Runs the Love2D core.\n" ..
    "- ginga: Runs the Ginga core.\n" ..
    "- html5_webos: Builds for HTML5 on WebOS.\n" ..
    "- html5_tizen: Builds for HTML5 on Tizen.\n" ..
    "- html5_ginga: Runs the Ginga core for HTML5.\n" ..
    "- html5: Runs the standard HTML5 core.\n" ..
    "- nintendo_wii: Builds for the Nintendo Wii.\n" ..
    "\n" ..
    "Usage:\n" ..
    "- To run a command, use: ./cli.sh <command> <game_path> -".."-core <core_name> [options]\n" ..
    "- For example: ./cli.sh build ./examples/asteroids/game.lua -".."-core ginga"
    print(help_message)
else
    print('command not found: '..command)
    os.exit(1)
end

--! @endcond
