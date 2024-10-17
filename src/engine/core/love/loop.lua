local function loop(std, game, application, dt)
    std.delta = dt * 1000
    std.milis = love.timer.getTime() * 1000
end

local function event_bus(std)
    std.bus.listen_std('pre_loop', loop)
end

local function install(std, game, application)
end

local P = {
    event_bus=event_bus,
    install=install
}

return P
