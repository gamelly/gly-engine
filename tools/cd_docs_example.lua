local cmd = function(c) assert(require('os').execute(c), c) end
local game = arg[1]
local file = './html/game.lua'

if game == '2games' then
    game = 'two_games'
end

if game == 'launcher' then
    cmd('./cli.sh build @'..game..' --core html5 --dist ./html/ --enginecdn')
elseif game == 'gridsystem' or game == 'maze3d' or game == 'two_games' then
    cmd('./cli.sh build @'..game..' --core html5 --dist ./html/ --enginecdn --fengari')
elseif game == 'pong' then
    cmd('./cli.sh build @'..game..' --core html5_micro --dist ./html/ --fengari --enginecdn')
else
    cmd('./cli.sh build @'..game..' --core html5_lite --dist ./html/ --fengari --enginecdn')
end
