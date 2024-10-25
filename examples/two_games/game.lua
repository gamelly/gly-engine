--! @see pong
--! @see asteroids

local function load(std, game)
    game.toggle = false

    game.pong1 = std.node.load('examples/pong/game.lua')
    game.pong2 = std.node.load('examples/asteroids/game.lua')

    game.pong1.data.width = game.width/2
    game.pong1.data.height = game.height

    game.pong2.config.offset_x = game.width/2
    
    game.pong2.data.width = game.width/2
    game.pong2.data.height = game.height

    std.node.spawn(game.pong1)
    std.node.spawn(game.pong2)
    std.node.pause(game.pong2, 'loop')
end

local function key(std, game)
    if std.key.press.b then
        game.toggle = not game.toggle
        if game.toggle then
            std.node.pause(game.pong1, 'loop')
            std.node.resume(game.pong2, 'loop')
        else
            std.node.resume(game.pong1, 'loop')
            std.node.pause(game.pong2, 'loop')
        end
    end
end

local P = {
    meta={
        title='2 Games',
        author='RodrigoDornelles',
        description='play asteroids and pong in the same time',
        version='1.0.0'
    },
    config={
        require='math.random i18n math'
    },
    callbacks={
        load=load,
        key=key
    }
}

return P;
