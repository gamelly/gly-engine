local interfaces = {}

local function add_app(self, application)

end

local function cols()
    local col = {
        add_app = add_app
    }

    interfaces[#interfaces + 1] = col
    return col
end

local function event_bus(std, game, application)
    
end

local function install(std, game, application)
    std=std or {}
    std.ui = std.ui or {}
    std.ui.cols = cols
end

local P = {
    event_bus=event_bus,
    install=install
}

return P
