local function install(std, game, application)
    application.callbacks.loop = application.callbacks.loop or function () end
    local update = function(dt)
        game.dt = dt * 1000
        game.milis = love.timer.getTime() * 1000
        game.fps = love.timer.getFPS()
        application.callbacks.loop(std, game)
    end

    if love then
        love.update = update
    end

    return {update=update}
end

local P = {
    install=install
}

return P
