local zeebo_pipeline = require('src/lib/util/pipeline')

--! @short safe load game
--! @brief search by game in filesystem / lua modules
--! @li https://love2d.org/wiki/love.filesystem.getSource
local function loadgame(game_file)
    if type(game_file) == 'table' then
        return game_file
    end
    
    local cwd = '.'
    local application = type(game_file) == 'function' and game_file
    local game_title = game_file and game_file:gsub('%.lua$', '') or 'game'


    if not application and game_file and game_file:find('\n') then
        local ok, app = pcall(load, game_file)
        if not ok then
            ok, app = pcall(loadstring, game_file)
        end
        application = ok and app
    else
        if love and love.filesystem and love.filesystem.getSource then
            cwd = love.filesystem.getSource()
        end
        if not application then
            application = loadfile(cwd..'/'..game_title..'.lua')
        end
        if not application then
            local ok, app = pcall(require, game_title)
            application = ok and app
        end
    end

    while application and type(application) == 'function' do
        application = application()
    end

    return application
end

local function register(self, register_func)
    local listener_func = function(event_name)
        local filtered_events = {}

        do
            local index = 1
            while index <= #self.event do
                local event = self.event[index][event_name]
                if event then
                    filtered_events[#filtered_events + 1] = event
                end
                index = index + 1
            end
        end

        return function(a, b, c, d, e, f)
            local index = 1
            while index <= #filtered_events do
                filtered_events[index](self.std, self.game, self.application, a, b, c, d, e, f)
                index = index + 1
            end
        end
    end

    self.pipeline[#self.pipeline + 1] = function()
        register_func(listener_func)
    end

    return self
end

local function package(self, module_name, module, custom)
    local system = module_name:sub(1, 1) == '@'
    local name = system and module_name:sub(2) or module_name
    local should_install = self.list_append(name)

    if system then
        self.stdlib_required[name] = true
    end

    self.pipeline[#self.pipeline + 1] = function ()
        if not self.list_exist(name) then return end
        if not system and not self.lib_required[name] then return end
        
        local try_install = function()
            local m = module.install(self.std, self.game, self.application, custom, module_name)
            if m.event then
                self.event[#self.event + 1] = m.event
            end
        end
        
        local foo, bar = pcall(try_install)
        if not foo then print(bar) return end
        
        if system then
            self.stdlib_installed[name] = true
        else
            self.lib_installed[name] = true
        end
    end

    return self
end

local function require(std, game, application)
    local application_require = application.config and application.config.require or ''
    local next_library = application_require:gmatch('%S+')
    local self = {
        -- objects
        std=std,
        game=game,
        application=application,
        -- methods
        register = register,
        package = package,
        -- data
        event = {},
        list = {},
        lib_optional = {},
        lib_required = {},
        lib_installed = {},
        stdlib_required = {},
        stdlib_installed = {},
        -- internal
        pipeline = {},
        pipe = zeebo_pipeline.pipe
    }
    
    self.list_exist = function (name)
        return self.lib_optional[name] or self.lib_required[name] or self.stdlib_required[name]
    end
    self.list_append = function (name)
        if not self.list_exist(name) then
            self.list[#self.list + 1] = name
        end
    end
    self.run = function()
        local index = 1
        zeebo_pipeline.run(self)
        while index <= #self.list do
            local name = self.list[index]
            if self.stdlib_required[name] and not self.stdlib_installed[name] then
                error('system library not loaded: '..name)
            end
            if self.lib_required[name] and not self.lib_installed[name] then
                error('library not loaded: '..name)
            end
            index = index + 1
        end
    end

    repeat
        local lib = next_library()
        if lib then
            local name, optional = lib:match('([%w%.]+)([?]?)')
            self.list_append(name)
            if optional and #optional > 0 then
                self.lib_optional[name] = true
            else
                self.lib_required[name] = true
            end
        end
    until not lib

    return self
end

local function install(std, game, application, exit_func)
    std.game = std.game or {}
    std.game.load = loadgame
    return {load=loadgame}
end

local P = {
    load={install=install},
    loadgame = loadgame,
    require = require
}

return P
