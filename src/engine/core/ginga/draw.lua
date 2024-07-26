local bit = require('bit32')

--! @cond
local canvas = nil
local game = nil
--! @endcond

local function color(c)
    local R = bit.band(bit.rshift(c, 24), 0xFF)
    local G = bit.band(bit.rshift(c, 16), 0xFF)
    local B = bit.band(bit.rshift(c, 8), 0xFF)
    local A = bit.band(bit.rshift(c, 0), 0xFF)
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
    return std.draw
end

local P = {
    install=install
}

return P