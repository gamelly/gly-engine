local function loop(std, game, application, dt)
    game.dt = dt * 1000
    game.milis = love.timer.getTime() * 1000
    game.fps = love.timer.getFPS()
    application.callbacks.loop(std, game)
end

local function event_bus(std)
    std.bus.listen_std('loop', loop)
end

local function install(std, game, application)
    application.callbacks.loop = application.callbacks.loop or function () end
end

local P = {
    event_bus=event_bus,
    install=install
}

return P
