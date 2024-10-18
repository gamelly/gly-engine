--! @defgroup std
--! @{
--! @defgroup draw
--! @{

--! @hideparam std
--! @hideparam engine
--! @todo refact
--! @pre the <b>mode 3</b> require @c math
--! 
--! @param show @c integer
--! @li mode 1: FPS
--! @li mode 2: FPS / FPS Limit
--! @li mode 3: FPS Real Time / FPS / FPS Limit
--! @param x @c double
--! @param y @c double
local function fps(std, engine, show, pos_x, pos_y)
    local x = engine.current.offset_x + pos_x
    local x = engine.current.offset_y + pos_y
    local s = 4
    self.std.draw.color(0xFFFF00FF)
    if show >= 1 then
        self.std.draw.rect(0, x, y, 40, 24)
    end
    if show >= 2 then
        self.std.draw.rect(0, x + 48, y, 40, 24)
    end
    if show >= 3 then
        self.std.draw.rect(0, x + 96, y, 40, 24)
    end
    self.std.draw.color(0x000000FF)
    self.std.draw.font('Tiresias', 16)
    if show >= 3 then
        local fps = self.std.math.floor and self.std.math.floor((1/self.game.dt) * 1000) or '--'
        self.std.draw.text(x + s, y, fps)
        s = s + 46
    end
    if show >= 1 then
        self.std.draw.text(x + s, y, self.game.fps)
        s = s + 46
    end
    if show >= 2 then
        self.std.draw.text(x + s, y, self.game.fps_max)
        s = s + 46
    end
end

--! @}
--! @}

local function event_bus(std, game, application)
    --! @todo this
end


local function install(std, engine, application)
    std.draw.fps = function(show, x, y)
        fps(std, engine, show, x, y)
    end

    return {
        std={draw={fps=std.draw.fps}}
    }
end

local P = {
    event_bus=event_bus,
    install=install
}

return P
