local decorators = require('src/lib/engine/decorators')
local bit = require('bit32')

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

local function rect(a,b,c,d,e,f)
    if f and canvas.drawRoundRect then
        canvas:drawRoundRect(a,b,c,d,e,f)
        return
    end
    canvas:drawRect(a,b,c,d,e)
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

local function install(std)
    std = std or {}
    std.draw = std.draw or {}
    std.draw.clear=clear
    std.draw.color=color
    std.draw.rect=rect
    std.draw.text=text
    std.draw.font=font
    std.draw.line=line
    std.draw.poly=decorators.poly(0, nil, line)
    return std.draw
end
