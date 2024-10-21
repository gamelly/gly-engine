--! @see pong
--! @see asteroids

local function load(std, game)
    game.toggle = false

    game.pong1 = std.game.load('examples/pong/game.lua')
    game.pong2 = std.game.load('examples/asteroids/game.lua')

    game.pong1.data.width = game.width/2
    game.pong1.data.height = game.height

    game.pong2.config.offset_x = game.width/2
    
    game.pong2.data.width = game.width/2
    game.pong2.data.height = game.height

    std.bus.spawn(game.pong1)
    std.bus.spawn(game.pong2)
    std.bus.pause('loop', game.pong2)
end

local function key(std, game)
    if std.key.press.b then
        game.toggle = not game.toggle
        if game.toggle then
            std.bus.pause('loop', game.pong1)
            std.bus.resume('loop', game.pong2)
        else
            std.bus.resume('loop', game.pong1)
            std.bus.pause('loop', game.pong2)
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
