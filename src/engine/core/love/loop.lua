local function loop(std, game, application, dt)
    game.dt = dt * 1000
    game.milis = love.timer.getTime() * 1000
    game.fps = love.timer.getFPS()
    application.callbacks.loop(std, game)
end

local function install(std, game, application)
    application.callbacks.loop = application.callbacks.loop or function () end

    return {
        event={loop=loop}
    }
end

local P = {
    install=install
}

return P
