local buses = {
    list = {},
    dict = {},
    queue = {},
    pause = {}
}

--! @defgroup std
--! @{
--! @defgroup bus
--! @{
--! @short Event Bus System
--! @warning <strong>This is an advanced API!</strong>@n only for advanced programmers,
--! You might be lost if you are a beginner.
--! @brief internal mechanisms communication system,
--! but can also be used externally.

--! @short send signal in next frame
--! @par Example
--! @code
--! std.bus.emit('player_death')
--! @endcode
local function emit_next(key, a, b, c, d, e, f)
    buses.queue[#buses.queue + 1] = {key, a, b, c, d, e, f}
end

--! @short send unique event
--! @details
--! Yes, @c abcdef is faster to implement and execute.
--! If you need more parameters than that, the problem is in your code.
--! In fact, love2d also does the same thing. https://love2d.org/wiki/love.event
--!
--! @par Example
--! @code
--! std.bus.emit('on_shoot', x1, y1, x2, y2)
--! @endcode
local function emit(key, a, b, c, d, e, f)
    local index1, index2 = 1, 1
    local prefixes = {'pre_', '', 'post_'}
    while index1 <= #prefixes do
        index2 = 1
        local prefix = prefixes[index1]
        local bus = buses.dict[prefix..key]
        while bus and index2 <= #bus do
            local func = bus[index2]
            if not buses.pause[func] then
                func(a, b, c, d, e, f)
            end
            index2 = index2 + 1
        end
        index1 = index1 + 1
    end
end

--! @short sender event function
--! @par Example
--! @code
--! love.filedropped = std.bus.trigger('file_dropped')
--! @endcode
local function trigger(key)
    return function (a, b, c, d, e, f)
        emit(key, a, b, c, d, e, f)
    end
end

--! @short subscribe event
--! @par Example
--! @code
--! std.bus.listen('player_death', function()
--!     print('game over!')
--! end)
--! @endcode
local function listen(key, handler_func)
    if not buses.dict[key] then
        buses.list[#buses.list + 1] = key
        buses.dict[key] = {}
    end
    local index = #buses.dict[key] + 1
    buses.dict[key][index] = handler_func 
end

--! @short assign application
--! @hideparam std
--! @hideparam engine
--! @brief assign application callbacks as bus events
--! @par Example
--! @code{.java}
--! local function load(std, app)
--!     app.game1 = std.game.load('examples/pong/game.lua')
--!     app.game2 = std.game.load('examples/asteroids/game.lua')
--! 
--!     app.game1.data.width = game.width/2
--!     app.game1.data.height = game.height
--! 
--!     app.game2.config.offset_x = game.width/2
--!     app.game2.data.width = game.width/2
--!     app.game2.data.height = game.height
--! 
--!     std.bus.spawn(app.game1)
--!     std.bus.spawn(app.game2)
--! end
--! @endcode
local function spawn(std, engine, application)
    local callbacks = application.callbacks

    for event, callback in pairs(callbacks) do
        listen(event, function()
            if not buses.pause[event..application.config.id] then
                local data = application.data or {}
                engine.current = application
                application.callbacks[event](std, data)
            end
        end)
    end
end

--! @short disable application callback
--! @brief stop receive specific event int the application
local function pause(key, application)
    buses.pause[key..application.config.id] = true
end

--! @short enable application callback
--! @brief return to receiving specific event in the application
local function resume(key, application)
    buses.pause[key..application.config.id] = false
end

--! @}
--! @}

local function install(std, engine)
    std = std or {}
    std.bus = std.bus or {}
    
    std.bus.emit = emit
    std.bus.listen = listen
    std.bus.trigger = trigger
    std.bus.pause = pause
    std.bus.resume = resume
    std.bus.emit_next = emit_next

    std.bus.listen_std = function(key, handler_func)
        listen(key, function(a, b, c, d, e, f)
            handler_func(std, a, b, c, d, e, f)
        end)
    end

    std.bus.listen_std_engine = function(key, handler_func)
        listen(key, function(a, b, c, d, e, f)
            handler_func(std, engine, a, b, c, d, e, f)
        end)
    end

    listen('pre_loop', function()
        local index = 1
        while index <= #buses.queue do
            local pid = buses.queue[index]
            emit(pid[1], pid[2], pid[3], pid[4], pid[5], pid[6])
            index = index + 1
        end
        buses.queue = {}
    end)

    std.bus.spawn = function(application)
        spawn(std, engine, application)
    end

    return {
        bus=std.bus
    }
end

local P = {
    install=install
}

return P
