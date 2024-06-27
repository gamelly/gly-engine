local math = require('math')

local function init(std, game)
    game.asteroid_large = {9,0, 9,5, 5,4, 0,10, 6,13, 3,16, 5,20, 10,22, 16,22, 19,19, 20,17, 22,14, 22,11, 18,4, 9,0}
    game.asteroid_mid =  {2,0, 0,7, 3,11, 3,16, 8,17, 12,15, 16,14, 12,4, 16,1, 6,0, 2,0}
    game.asteroid_small = {1,0, 0,1, 1,3, 1,4, 0,6, 2,7, 4,7, 6,6, 7,5, 7,1, 4,1, 3,2, 1,0}
    game.asteroid_mini = {2,0, 2,2, 0,2, 0,4, 1,6, 2,6, 2,5, 5,5, 6,3, 4,2, 4,0, 2,0}
end

local function loop(std, game)
 
end

local function draw(std, game)
    std.draw.clear('black')
    std.draw.color('white')
    local y1 = std.math.saw(std.math.cycle(game.milis, 1000)) * 10
    local x2 = math.cos(std.math.cycle(game.milis, 1000) * 6.28) * 10
    local y2 = math.cos(std.math.cycle(game.milis, 1000) * 12) * 10
    local x3 = math.cos(std.math.cycle(game.milis, 500) * 6.28) * 10
    local y3 = math.sin(std.math.cycle(game.milis, 500) * 6.28) * 10
    std.draw.poly('fill', game.asteroid_mini, 100, 200 + y1, 5)
    std.draw.poly('fill', game.asteroid_small, 200, 200 + y2, 5)
    std.draw.poly('fill', game.asteroid_mid, 300 + x2, 200 + y2, 5)
    std.draw.poly('fill', game.asteroid_large, 400 + x3 , 200 + y3, 5)
    std.draw.poly('line', game.asteroid_mini, 100, 400, 5)
    std.draw.poly('line', game.asteroid_small, 200, 400, 5)
    std.draw.poly('line', game.asteroid_mid, 300, 400, 5)
    std.draw.poly('line', game.asteroid_large, 400, 400, 5)
end

local function exit(std, game)

end

local P = {
    meta={
        title='Asteroids',
        description='',
        version='1.0.0'
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        exit=exit
    }
}

return P;
