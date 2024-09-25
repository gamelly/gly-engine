local key_bindings = {
    ['return']='enter',
    up='up',
    left='left',
    right='right',
    down='down',
    z='red',
    x='green',
    c='yellow',
    v='blue',
}

local function keydown(std, game, application, real_key)
    local key = key_bindings[real_key]
    if key then
        std.key.press[key] = 1
    end
end

local function keyup(std, game, application, real_key)
    local key = key_bindings[real_key]
    if key then
        std.key.press[key] = 0
    end
end

local function install(std, game, application)
    return {
        event={
            keydown=keydown,
            keyup=keyup
        }
    }
end

local P = {
    install=install
}

return P
