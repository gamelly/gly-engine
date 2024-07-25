local function install(std, game, application)
    application.callbacks.loop = application.callbacks.loop or function () end
    local update = function(dt)
        game.dt = dt * 1000
        game.milis = love.timer.getTime() * 1000
        game.fps = love.timer.getFPS()
        application.callbacks.loop(std, game)
    end

    if love then
        if love.update then
            local old_update = love.update
            love.update = function(dt)
                old_update(dt)
                update(dt)
            end
        else
            love.update = update
        end
    end

    return {update=update}
end

local P = {
    install=install
}

return P
