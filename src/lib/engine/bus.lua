local buses = {
    list = {},
    dict = {}
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

--! @par Example
--! @code
--! function love.update(dt)
--!     std.bus.trigger('loop', dt)
--! end
--! @endcode
local function spawn(key, a, b, c, d, e, f)
    local index = 1
    local bus = buses.dict[key]
    while bus and index <= #bus do
        bus[index](a, b, c, d, e, f)
        index = index + 1
    end
end

--! @par Example
--! @code
--! love.update = std.bus.trigger('loop')
--! @endcode
local function trigger(key)
    return function (a, b, c, d, e, f)
        spawn(key, a, b, c, d, e, f)
    end
end

--! @par Example
--! @code
--! std.bus.listen('loop', function(dt)
--!     print(dt)
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

--! @}
--! @}

local function install(std, game, application)
    std = std or {}
    std.bus = std.bus or {}
    
    std.bus.spawn = spawn
    std.bus.listen = listen
    std.bus.trigger = trigger

    std.bus.listen_std = function(key, handler_func)
        listen(key, function(a, b, c, d, e, f)
            handler_func(std, game, application, a, b, c, d, e, f)
        end)
    end

    std.bus.listen_safe = function(key, handler_func)
        listen(key, function(a, b, c, d, e, f)
            handler_func(std, game, a, b, c, d, e, f)
        end)
    end

    return {
        bus=std.bus
    }
end

local P = {
    install=install
}

return P
