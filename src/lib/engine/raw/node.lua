local buses = {
    list = {},
    pause = {},
}

--! @defgroup std
--! @{
--! @defgroup node
--! @{
--! @warning <strong>This is an advanced API!</strong>@n only for advanced programmers,
--! You might be lost if you are a beginner.
--!
--! ## Event Direct Message
--! @startuml
--! artifact node_1 as "Node 1"
--! artifact node_2 as "Node 2"
--! node_1 -> node_2
--! @enduml
--! @li Node 1
--! @code{.java}
--! std.node.emit(node_2, 'say', 'hello!')
--! @endcode
--!
--! ## Event Bus Registering
--! @par Parents
--! @startmindmap
--! * Root
--! ** Node 1
--! *** Node 2
--! ** Node 3
--! @endmindmap
--! @li Root
--! @code{.java}
--! std.node.spawn(node_1)
--! std.node.spawn(node_3)
--! @endcode
--! @li Node 1
--! @code{.java}
--! std.node.spawn(node_2)
--! @endcode
--!
--! @par Custom Events
--! @startuml
--! artifact node_1 as "Node 1"
--! artifact node_2 as "Node 2"
--! artifact node_3 as "Node 3"
--! 
--! process event_bus as "Event Bus" 
--! node_1 .> node_2: spawn
--! event_bus --> node_2
--! event_bus <-- node_3
--! @enduml
--!
--! @li Node 3
--! @code{.java}
--! std.bus.emit('say', 'hello for everyone!')
--! @endcode
--!
--! @par Engine Events
--! @startuml
--! folder core {
--!  folder love2d
--! }
--! process event_bus as "Event Bus"
--! artifact node_1 as "Node 1"
--! artifact node_2 as "Node 2"
--! 
--! love2d -> event_bus: event
--! event_bus --> node_2: event
--! node_1 .> node_2:spawn
--! @enduml

--! @hideparam std
--! @short send event to node
--! @par Tip
--! You can send message to "not spawned" node, as if he were an orphan.
--! @par Alternatives
--! @li @b std.node.emit_root send event to first node.
--! @li @b std.node.emit_parent send event to the node that registered current.
local function emit(std, application, key, a, b, c, d, e, f)
    local callback = application.callbacks[key]
    if not buses.pause[key..tostring(application)] and callback then
        return callback(std, application.data, a, b, c, d, e, f)
    end
end

--! @short create new node
--! @note When build the main game file, it will be directly affected by the bundler,
--! if it finds a path to the game it will be unified.
--! @par Example
--! @code{.java}
--! local game = std.node.load('examples/pong/game.lua')
--! print(game.meta.title)
--! @endcode
local function load(application)
end

--! @short register node to event bus
--! @hideparam std
--! @hideparam engine
--! @par Example
--! @code{.java}
--! local game = std.node.load('examples/pong/game.lua')
--! std.node.spawn(game)
--! @endcode
local function spawn(application)
    local index = #buses.list + 1
    buses.list[index] = application
end

--! @short disable node callback
--! @brief stop receive specific event int the application
--! @par Example
--! @code{.java}
--! if not paused and std.key.press.menu then
--!     std.node.pause(minigame, 'loop')
--! end
--! @endcode
local function pause(application, key)
    buses.pause[key..tostring(application)] = true
end

--! @short enable node callback
--! @brief return to receiving specific event in the application
--! @par Example
--! @code{.java}
--! if paused and std.key.press.menu then
--!     std.node.resume(minigame, 'loop')
--! end
--! @endcode
local function resume(application, key)
    buses.pause[key..tostring(application)] = false
end
--! @}
--! @}

--! note note remove
local function event_bus(std, engine, key, a, b, c, d, e, f)
    local index = 1
    
    while index <= #buses.list do
        local application = buses.list[index]
        if engine.current ~= application then
            engine.current = application
        end

        local ret = emit(std, application, key, a, b, c, d, e, f)
        
        if ret ~= nil then
            engine.bus_emit_ret(key, ret)
        end
        
        index = index + 1
    end
end

local function install(std, engine, config)
    std.node = std.node or {}

    std.node.spawn = spawn
    std.node.pause = pause
    std.node.resume = resume
    std.node.load = config.loadgame

    std.bus.listen_all(function(key, a, b, c, d, e, f)
        event_bus(std, engine, key, a, b, c, d, e, f)
    end)

    std.node.emit = function(application, key, a, b, c, d, e, f)
        return emit(std, application, key, a, b, c, e, f)
    end

    std.node.emit_root = function(key, a, b, c, d, e, f)
        return emit(std, engine.root, key, a, b, c, e, f)
    end

    std.node.emit_parent = function(key, a, b, c, d, e, f)
        return emit(std, engine.current.config.parent, key, a, b, c, e, f)
    end
end

local P = {
    install=install
}

return P
