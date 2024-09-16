--! @defgroup std
--! @{
--! @defgroup game
--! @{

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

--! @}
--! @}

--! @cond
local function install(std, game, application, exit_func)
    std = std or {}
    std.game = std.game or {}
    
    local app = {
        callbacks=application.callbacks,
        exit=exit_func,
        std=std,
        game=game
    }

    std.game.reset = reset(app)
    std.game.exit = exit(app)

    return std.game
end
--! @endcond

local P = {
    install=install
}

return P
