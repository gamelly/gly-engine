--! @defgroup std
--! @{
--! @defgroup game
--! @{

--! @hideparam self
local function reset(self)
    return function()
        if self.callbacks.exit then
            self.callbacks.exit(self.std, self.game)
        end
        if self.callbacks.init then
            self.callbacks.init(self.std, self.game)
        end
    end
end

--! @hideparam self
local function exit(self)
    return function()
        if self.callbacks.exit then
            self.callbacks.exit(self.std, self.game)
        end
        if self.exit then
            self.exit()
        end
    end
end


--! @hideparam self
local function title(self, window_name)
    if self.cfg.set_title then
        self.cfg.set_title(window_name)
    end
end

--! @}
--! @}

--! @cond
local function install(std, game, application, config)
    std = std or {}
    std.game = std.game or {}
    
    local app = {
        cfg = config,
        callbacks=application.callbacks,
        exit=exit_func,
        std=std,
        game=game
    }

    std.game.title = function(t) title(app, t) end
    std.game.reset = reset(app)
    std.game.exit = exit(app)
    std.game.get_fps = config.fps

    return std.game
end
--! @endcond

local P = {
    install=install
}

return P
