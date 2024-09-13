local function install(self)
    local std = self and self.std or {}
    local game = self and self.game or {}
    local event = self and self.event or {}
    local application = self and self.application or {}
    
    std.loop = std.loop or {}
    event.loop = event.loop or {}
    application.callbacks.loop = application.callbacks.loop or function () end

    event.loop[#event.loop + 1] = function(dt)
        game.dt = dt * 1000
        game.milis = love.timer.getTime() * 1000
        game.fps = love.timer.getFPS()
        application.callbacks.loop(std, game)
    end

    if love and not love.update then
        love.update = function(dt)
            local index = 1
            while index <= #event.loop do
                event.loop[index](dt)
                index = index + 1
            end
        end
    end

    return {
        event={loop=event.loop}
    }
end

local P = {
    install=install
}

return P
