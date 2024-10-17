local zeebo_pipeline = require('src/lib/util/pipeline')
local application_default = require('src/lib/object/application')

local function register(std, game, application)
    local callbacks = application.callbacks

    for event, callback in pairs(callbacks) do
        std.bus.listen(event, function()
            application.callbacks[event](std, game)
        end)
    end
end

local function normalize(application)
    if not application then return nil end

    if application.Game then
        application = application.Game
    end

    if application.new and type(application.new) == 'function' then
        application = application.new()
    end

    if application and application.meta and application.callbacks then
        return application
    end

    local normalized_aplication = {
        meta = {},
        config = {},
        callbacks = {}
    }

    for key, value in pairs(application) do
        if application_default.meta[key] then
            normalized_aplication.meta[key] = value
        elseif type(value) == 'function' then
            normalized_aplication.callbacks[key] = value
        else
            normalized_aplication.config[key] = value
        end
    end

    return normalized_aplication
end

--! @defgroup std
--! @{
--! @defgroup game
--! @{

--! @renamefunc load
--! @short safe load game
--! @pre require @c load
--! @brief search by game in filesystem / lua modules
--! @li https://love2d.org/wiki/love.filesystem.getSource
local function loadgame(game_file)
    if type(game_file) == 'table' or type(game_file) == 'userdata' then
        return normalize(game_file)
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
    if not application and io and io.open and game_file then
        local app_file = io.open(game_file)
        if app_file then
            local app_src = app_file:read('*a')
            local ok, app = pcall(load, app_src)
            if not ok then
                ok, app = pcall(loadstring, app_src)
            end
            application = ok and app
            app_file:close()
        end
    end

    while application and type(application) == 'function' do
        application = application()
    end

    return normalize(application)
end

--! @}
--! @}

local function package(self, module_name, module, custom)
    local system = module_name:sub(1, 1) == '@'
    local name = system and module_name:sub(2) or module_name

    if system then
        self.stdlib_required[name] = true
    end

    self.pipeline[#self.pipeline + 1] = function ()
        if not self.list_exist(name) then return end
        if not system and not self.lib_required[name] then return end
        
        local try_install = function()
            module.install(self.std, self.game, self.application, custom, module_name)
            if module.event_bus then
                module.event_bus(self.std, self.game, self.application)
            end
        end
        
        if not pcall(try_install) then return end
        
        if system then
            self.stdlib_installed[name] = true
        else
            self.lib_installed[name] = true
        end
    end

    return self
end

local function require(std, game, application)
    if not application then
        error('game not found!')
    end

    local application_require = application.config and application.config.require or ''
    local next_library = application_require:gmatch('%S+')
    local self = {
        -- objects
        std=std,
        game=game,
        application=application,
        -- methods
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
    std.game.register = function(app) return register(std, game, app) end
    return {load=loadgame}
end

local P = {
    install=install,
    loadgame = loadgame,
    require = require
}

return P
