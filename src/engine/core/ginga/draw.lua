local math = require('math')

--! @cond
local canvas = nil
local game = nil
--! @endcond

local function color(c)
    local R = math.floor(c/0x1000000)
    local G = math.floor(c/0x10000) - (R * 0x100)
    local B = math.floor(c/0x100) - (R * 0x10000) - (G * 0x100)
    local A = c - (R * 0x1000000) - (G * 0x10000) - (B * 0x100)
    canvas:attrColor(R, G, B, A)
end

local function clear(c)
    color(c)
    canvas:drawRect('fill', 0, 0, game.width, game.height)
end

local function rect(mode, x, y, width, height)
    canvas:drawRect(mode == 0 and 'fill' or 'frame', x, y, width, height)
end

local function text(x, y, text)
    if x and y then
        canvas:drawText(x, y, text)
    end
    return canvas:measureText(text or x)
end

local function font(a,b)
    canvas:attrFont(a,b)
end

local function line(x1, y1, x2, y2)
    canvas:drawLine(x1, y1, x2, y2)
end

local function install(std, lgame, application, ginga)
    canvas = ginga.canvas
    game = lgame
    std = std or {}
    std.draw = std.draw or {}
    std.draw.clear=clear
    std.draw.color=color
    std.draw.rect=rect
    std.draw.text=text
    std.draw.font=font
    std.draw.line=line
    local index = #application.internal.fixed_loop + 1
    application.internal.fixed_loop[index] = function ()
        canvas:attrColor(0, 0, 0, 0)
        canvas:clear()
        application.callbacks.draw(std, game)
        if game.fps_show and game.fps_show >= 0 and std.draw.fps then
            std.draw.fps(game.fps_show, 8, 8)
        end
        canvas:flush()
    end
    return std.draw
end

local P = {
    install=install
}

return P