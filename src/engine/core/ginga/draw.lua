local math = require('math')

--! @cond
local canvas = nil
local application = nil
local game = nil
local std = nil
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

local function font(name, size)
    if type(name) == 'number' and not size then
        size = name
        name = 'Tiresias'
    end
    canvas:attrFont(name, size)
end

local function line(x1, y1, x2, y2)
    canvas:drawLine(x1, y1, x2, y2)
end

local function image(src, x, y)
    local image = std.mem.cache('image'..src, function()
        return canvas:new('../assets/'..src)
    end)
    canvas:compose(x, y, image)
end

local function event_bus()
    std.bus.listen_safe('draw', application.callbacks.draw)
end

local function install(lstd, lgame, lapplication, ginga)
    canvas = ginga.canvas
    application = lapplication
    game = lgame
    std = lstd
    std = std or {}
    std.draw = std.draw or {}
    std.draw.image=image
    std.draw.clear=clear
    std.draw.color=color
    std.draw.rect=rect
    std.draw.text=text
    std.draw.font=font
    std.draw.line=line

    return {
        draw=std.draw
    }
end

local P = {
    event_bus = event_bus,
    install = install
}

return P