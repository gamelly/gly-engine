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
local function event_ginga(std, game, application, evt)
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
    application.callbacks.loop = application.callbacks.loop or function () end

    return {
        event={ginga=event_ginga}
    }
end

local P = {
    install=install
}

return P
