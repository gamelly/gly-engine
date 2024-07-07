local os = require('os')
local zeebo_args = require('src/shared/args')
local zeebo_fs = require('src/cli/fs')

--! @cond
local run = zeebo_args.has(arg, 'run')
local coverage = zeebo_args.has(arg, 'coverage')
local core = zeebo_args.get(arg, 'core', 'ginga')
local screen = zeebo_args.get(arg, 'screen', '1280x720')
local command = zeebo_args.param(arg, {'core', 'screen'}, 1, 'help')
local game = zeebo_args.param(arg, {'core', 'screen'}, 2, '')

local core_list = {
    repl={
        src='src/lib/repl/main.lua',
        exe='lua src/lib/repl/main.lua '..game,
        post_exe='lua dist/main.lua'
    },
    love={
        src='src/lib/love2d/main.lua',
        exe='love src/lib/love2d --screen '..screen..' '..game,
        post_exe='love dist --screen '..screen
    },
    ginga={
        src='src/lib/ginga/main.lua',
        post_exe='ginga dist/main.ncl -s '..screen,
        extras={
            'src/lib/ginga/main.ncl'
        }
    }
}

if command == 'run' then
    if not core_list[core] or not core_list[core].exe then
        print('this core cannot be runned!')
        os.exit(1)
    end
    os.exit(os.execute(core_list[core].exe) and 0 or 1)
elseif command == 'test-self' then
    coverage = coverage and '-lluacov' or ''
    local ok = os.execute('lua '..coverage..' ./tests/test_lib_common_math.lua')
    local ok = ok and os.execute('lua '..coverage..' ./tests/test_shared_args.lua')
    if #coverage > 0 then
        os.execute('luacov src')
    end
    if not ok then
        os.exit(1)
    end
elseif command == 'build' then
    -- clean dist
    if os.execute('rm --version > /dev/null 2> /dev/null') then
        os.execute('mkdir -p ./dist/')
        os.execute('rm -Rf ./dist/*')
    else
        os.execute('rmdir /s /q .\\dist\\*')
        os.execute('mkdir .\\dist')
    end
    
    -- check core
    if not core_list[core] then
        print('this core cannot be build!')
        exit(1)
    end
    
    -- move game
    if game and #game > 0 then
        zeebo_fs.move(game, 'dist/game.lua')
    end

    -- core move
    local index = 1
    local core = core_list[core]
    zeebo_fs.build(core.src, './dist')
    if core.extras then
        while index <= #core.extras do
            local file = core.extras[index]
            zeebo_fs.move(file, './dist/'..file:gsub('.*/', ''))
            index = index + 1
        end
    end

    if run then
        if not core.post_exe then
            print('this core cannot be runned after build!')
            exit(1)
        end
        os.exit(os.execute(core.post_exe) and 0 or 1)
    end
else
    print('command not found: '..command)
    os.exit(1)
end

--! @endcond
