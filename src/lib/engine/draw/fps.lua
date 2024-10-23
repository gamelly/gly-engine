--! @defgroup std
--! @{
--! @defgroup draw
--! @{

--! @renamefunc fps 
--! @hideparam std
--! @hideparam engine
--! @todo change std.draw.text to std.draw.tui
--! @pre the <b>mode 3</b> require @c math
--! 
--! @param show @c integer
--! @li mode 1: FPS
--! @li mode 2: FPS / FPS Limit
--! @li mode 3: FPS Real Time / FPS / FPS Limit
--! @param pos_x @c double
--! @param pos_y @c double
local function draw_fps(std, engine, show, pos_x, pos_y)
    if not show then return end

    local x = engine.current.offset_x + pos_x
    local y = engine.current.offset_y + pos_y
    local s = 4

    std.draw.color(0xFFFF00FF)

    if show >= 1 then
        std.draw.rect(0, x, y, 40, 24)
    end
    if show >= 2 then
        std.draw.rect(0, x + 48, y, 40, 24)
    end
    if show >= 3 then
        std.draw.rect(0, x + 96, y, 40, 24)
    end
    std.draw.color(0x000000FF)
    std.draw.font('Tiresias', 16)
    if show >= 3 then
        local fps = std.math.floor and std.math.floor((1/std.delta) * 1000) or '--'
        std.draw.text(x + s, y, fps)
        s = s + 46
    end
    if show >= 1 then
        std.draw.text(x + s, y, 'XX')
        s = s + 46
    end
    if show >= 2 then
        std.draw.text(x + s, y, engine.root.config.fps_max)
        s = s + 46
    end
end

--! @}
--! @}

local function event_bus(std, engine)
    std.bus.listen('post_draw', function()
        engine.current = engine.root
        draw_fps(std, engine, engine.root.config.show_fps, 8, 8)
    end)
end

local function install(std, engine)
    std.draw.fps = function(show, x, y)
        draw_fps(std, engine, show, x, y)
    end

    return {
        std={draw={fps=draw_fps}}
    }
end

local P = {
    event_bus=event_bus,
    install=install
}

return P
