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
local function install(self, exit_func)
    local std = self and self.std or {}
    local game = self and self.game or {}
    local application = self and self.application or {}

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
