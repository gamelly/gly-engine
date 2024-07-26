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

local function install(std)
    if love then
        love.keypressed = function(key)
            if key_bindings[key] then
                std.key.press[key_bindings[key]] = 1
            end
        end
        love.keyreleased = function(key)
            if key_bindings[key] then
                std.key.press[key_bindings[key]] = 0
            end
        end
    end

    return {}
end

local P = {
    install=install
}

return P
