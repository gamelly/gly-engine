--! @defgroup std
--! @{
--! @defgroup key
--! @{
--!
--! | input              | values |
--! | :----------------- | :----- |
--! | std.key.axis.x     | -1 0 1 |
--! | std.key.axis.y     | -1 0 1 |
--! | std.key.axis.a     | 0 1    |
--! | std.key.axis.b     | 0 1    |
--! | std.key.axis.c     | 0 1    |
--! | std.key.axis.d     | 0 1    |
--! | std.key.axis.menu  | 0 1    |
--! | std.key.press.a    | false true |
--! | std.key.press.b    | false true |
--! | std.key.press.c    | false true |
--! | std.key.press.d    | false true |
--! | std.key.press.menu | false true |
--!
--! @}
--! @}

local function real_key(std, engine, rkey, rvalue)
    local value = rvalue == 1 or rvalue == true
    local key = engine.key_bindings[rkey] or (std.key.axis[rkey] and rkey)
    if key then
        std.key.axis[key] = value and 1 or 0
        std.key.press[key] = value

        if key == 'right' or key == 'left' then
            std.key.axis.x = std.key.axis.right - std.key.axis.left
        end
        
        if key == 'down' or key == 'up' then
            std.key.axis.y = std.key.axis.down - std.key.axis.up
        end
        
        std.bus.emit('key')
    end
end

local function real_keydown(std, engine, key)
    real_key(std, engine, key, 1)
end

local function real_keyup(std, engine, key)
    real_key(std, engine, key, 0)
end

local function event_bus(std, engine)
    std.bus.listen_std_engine('rkey', real_key)
    std.bus.listen_std_engine('rkey1', real_keydown)
    std.bus.listen_std_engine('rkey0', real_keyup)
end

local function install(std, engine, key_bindings)
    engine.key_bindings = key_bindings or {}
    engine.keyboard = real_key
end

local P = {
    event_bus = event_bus,
    install = install
}

return P
