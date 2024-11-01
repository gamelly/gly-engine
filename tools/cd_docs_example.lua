local cmd = function(c) assert(require('os').execute(c), c) end
local game = arg[1]
local file = './html/game.lua'

cmd('./cli.sh build @'..game..' --core html5 --dist ./html/')

if game == 'dvdplayer' then
    cmd('cp assets/icon80x80.png ./html/icon80x80.png')
elseif game == 'launcher' then
    cmd('./cli.sh fs-replace ./html/game.lua ./html/game.lua --format http --replace https')
end
