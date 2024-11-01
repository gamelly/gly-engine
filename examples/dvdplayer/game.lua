local function init(std, game)
    game.x = game.width/2
    game.y = game.height/2
    game.size = 80
    game.hspeed = game.width/5000
    game.vspeed = game.height/4000
end

local function loop(std, game)
    game.x = std.math.clamp(game.x + (game.hspeed * std.delta), 0, game.width - game.size)
    game.y = std.math.clamp(game.y + (game.vspeed * std.delta), 0, game.height - game.size)
    if game.x == 0 or game.x == game.width - game.size then
        game.hspeed = -1 * game.hspeed
    end
    if game.y == 0 or game.y == game.height - game.size then
        game.vspeed = -1 * game.vspeed
    end
end

local function draw(std, game)
    std.draw.clear(std.color.black)
    std.draw.image('icon80x80.png', game.x, game.y)
end

local function exit(std, game)
end

local P = {
    meta={
        title='DVD Player',
        author='RodrigoDornelles',
        description='a logo bouncing between the corners',
        version='1.0.0'
    },
    assets={
      'assets/icon80x80.png:icon80x80.png'
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        exit=exit
    }
}

return P;
