local buses = {
    list = {},
    dict = {},
    queue = {}
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

local function spawn_next(key, a, b, c, d, e, f)
    buses.queue[#buses.queue + 1] = {key, a, b, c, d, e, f}
end

--! @par Example
--! @code
--! function love.update(dt)
--!     std.bus.trigger('loop', dt)
--! end
--! @endcode
local function spawn(key, a, b, c, d, e, f)
    local index1, index2 = 1, 1
    local prefixes = {'pre_', '', 'post_'}
    while index1 <= #prefixes do
        index2 = 1
        local prefix = prefixes[index1]
        local bus = buses.dict[prefix..key]
        while bus and index2 <= #bus do
            bus[index2](a, b, c, d, e, f)
            index2 = index2 + 1
        end
        index1 = index1 + 1
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
    std.bus.spawn_next = spawn_next

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

    listen('pre_loop', function()
        local index = 1
        while index <= #buses.queue do
            local pid = buses.queue[index]
            spawn(pid[1], pid[2], pid[3], pid[4], pid[5], pid[6])
            index = index + 1
        end
        buses.queue = {}
    end)

    return {
        bus=std.bus
    }
end

local P = {
    install=install
}

return P
