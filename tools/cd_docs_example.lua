local cmd = function(c) assert(require('os').execute(c), c) end
local game = arg[1]
local file = './html/game.lua'

if game == '2games' then
    game = 'two_games'
end

cmd('./cli.sh build @'..game..' --core html5 --dist ./html/')

if game == 'launcher' then
    cmd('./cli.sh fs-replace ./html/game.lua ./html/game.lua --format http: --replace https:')
end
