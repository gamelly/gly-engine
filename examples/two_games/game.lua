--! @see pong
--! @see asteroids

local function load(std, game)
    local game1 = std.node.load('examples/pong/game.lua')
    local game2 = std.node.load('examples/asteroids/game.lua')

    game.toggle = false
    game.ui_split = std.ui.grid('2x1')
        :add(game1)
        :add(game2)

    std.node.pause(game.ui_split:get_item(2), 'loop')
end

local function key(std, game)
    if std.key.press.b then
        local to_pause = game.ui_split:get_item(game.toggle and 2 or 1)
        local to_resume = game.ui_split:get_item(game.toggle and 1 or 2)
        std.node.pause(to_pause, 'loop')
        std.node.resume(to_resume, 'loop')
        game.toggle = not game.toggle
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
