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

local function install(self)
    local std = self and self.std or {}
    local event = self and self.event or {}

    event.key = event.key or {}
    event.key[#event.key + 1] = function(key, value)
        std.key.press[key] = value
    end

    if love and not love.keypressed and not love.keyreleased then
        love.keypressed = function(real_key)
            local key, index = key_bindings[real_key], 1

            while key and index <= #event.key do
                event.key[index](key, 1)
                index = index + 1
            end
        end
        love.keyreleased = function(real_key)
            local key, index = key_bindings[real_key], 1

            while key and index <= #event.key do
                event.key[index](key, 0)
                index = index + 1
            end
        end
    end

    return {}
end

local P = {
    install=install
}

return P
