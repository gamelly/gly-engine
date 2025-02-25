local cmd = function(c) assert(require('os').execute(c), c) end
local game = arg[1]
local file = './html/game.lua'

if game == '2games' then
    game = 'two_games'
end

if game == 'gridsystem' or game == 'maze3d' then
    cmd('./cli.sh build @'..game..' --core html5 --dist ./html/')
elseif game == 'launcher' then
    cmd('./cli.sh build @'..game..' --core html5 --dist ./html/')
    cmd('./cli.sh fs-replace ./html/game.lua ./html/game.lua --format http: --replace https:')
else
    cmd('./cli.sh build @'..game..' --core html5_lite --dist ./html/ --fengari --enterprise')
end
