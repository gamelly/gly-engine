local fixture190 = ''
local key_bindings={
    CURSOR_UP='up',
    CURSOR_DOWN='down',
    CURSOR_LEFT='left',
    CURSOR_RIGHT='right',
    RED='a',
    GREEN='b',
    YELLOW='c',
    BLUE='d',
    z='a',
    x='b',
    c='c',
    v='d',
    ENTER='a'
}

--! @li https://github.com/TeleMidia/ginga/issues/190
local function event_ginga(std, game, application, evt)
    if evt.class ~= 'key' then return end
    if not key_bindings[evt.key] then return end
    
    if #fixture190 == 0 and evt.key ~= 'ENTER' then
        fixture190 = evt.type
    end

    std.bus.emit('rkey', key_bindings[evt.key], fixture190 == evt.type)
end

local function event_bus(std)
    std.bus.listen_std('ginga', event_ginga)
end

local function install(std, game, application)
end

local P = {
    event_bus = event_bus,
    install=install
}

return P
