local os = require('os')
local args = require('src/shared/args')

local run = args.has(arg, 'run')
local game = args.get(arg, 'game', './examples/pong')
local core = args.get(arg, 'core', 'ginga')
local screen = args.get(arg, 'screen', '1280x720')

-- clean dist
os.execute('mkdir -p ./dist/')
os.execute('rm -Rf ./dist/*')

-- move game
os.execute('cp '..game..'/game.lua dist/game.lua')

-- move common lib
os.execute('cp src/lib/common/*.lua dist')

-- move engine
if core == 'ginga' then
    os.execute('cp src/lib/ginga/main.ncl dist/main.ncl')
    os.execute('cp src/lib/ginga/core.lua dist/main.lua')
elseif core == 'love' or core == 'love2d' then
    os.execute('cp src/lib/love2d/core.lua dist/main.lua')
else
    error('this core is dont supported!')
end

-- post execute game
if run then
    if core == 'ginga' then
        os.execute('ginga ./dist/main.ncl -s '..screen)
    elseif core == 'love' or core == 'love2d' then
        os.execute('love dist --screen '..screen)
    end
end
