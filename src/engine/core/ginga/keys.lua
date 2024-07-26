local fixture190 = ''
local key_bindings={
    CURSOR_UP='up',
    CURSOR_DOWN='down',
    CURSOR_LEFT='left',
    CURSOR_RIGHT='right',
    RED='red',
    GREEN='green',
    YELLOW='yellow',
    BLUE='blue',
    F6='red',
    z='red',
    x='green',
    c='yellow',
    v='blue',
    ENTER='enter'
}

--! @li https://github.com/TeleMidia/ginga/issues/190
local function event_loop(std, evt)
    if evt.class ~= 'key' then return end
    if not key_bindings[evt.key] then return end
    
    if #fixture190 == 0 and evt.key ~= 'ENTER' then
        fixture190 = evt.type
    end

    if fixture190 == evt.type then
        std.key.press[key_bindings[evt.key]] = 1
    else
        std.key.press[key_bindings[evt.key]] = 0
    end
end

local function install(std, game, application)
    std = std or {}
    application.internal.event_loop[#application.internal.event_loop + 1] = function (evt)
        event_loop(std, evt)
    end
    return std
end

local P = {
    install=install
}

return P
