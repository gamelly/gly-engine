local os = require('os')

local function args_get(args, arg, default)
    local index = 1
    local value = default    
    while index <= #args do
        local param = args[index]
        local nextparam = args[index + 1]
        if param:sub(1, 2) == '--' and param:sub(3, #param) == arg and nextparam and nextparam:sub(1, 2) ~= '--' then
            value = nextparam
        end 
        index = index + 1
    end
    return value
end

local function args_has(args, arg)
    local index = 1
    while index <= #args do
        local param = args[index]
        if param:sub(1, 2) == '--' and param:sub(3, #param) == arg then
            return true
        end 
        index = index + 1
    end
    return false
end

local run = args_has(arg, 'run')
local game = args_get(arg, 'game', './examples/pong')
local core = args_get(arg, 'core', 'ginga')
local screen = args_get(arg, 'screen', '1280x720')

-- clean dist
os.execute('mkdir -p ./dist/')
os.execute('rm -Rf ./dist/*')

-- move game
os.execute('cp '..game..'/game.lua dist/game.lua')

-- move common lib
os.execute('cp src/common/*.lua dist')

-- move engine
if core == 'ginga' then
    os.execute('cp src/engine/ginga/main.ncl dist/main.ncl')
    os.execute('cp src/engine/ginga/core.lua dist/main.lua')
elseif core == 'love' or core == 'love2d' then
    os.execute('cp src/engine/love2d/core.lua dist/main.lua')
else
    error('this core is dont supported!')
end

-- post execute game
if run then
    if core == 'ginga' then
        os.execute('ginga ./dist/main.ncl -s '..screen)
    elseif core == 'love' or core == 'love2d' then
        os.execute('love dist')
    end
end
