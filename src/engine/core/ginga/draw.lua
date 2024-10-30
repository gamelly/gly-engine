local math = require('math')
local util_decorator = require('src/lib/util/decorator')

local deafult_font_name = 'Tiresias'
local current_font_name = deafult_font_name
local current_font_size = 8

local function color(std, engine, canvas, tint)
    local c = tint
    local R = math.floor(c/0x1000000)
    local G = math.floor(c/0x10000) - (R * 0x100)
    local B = math.floor(c/0x100) - (R * 0x10000) - (G * 0x100)
    local A = c - (R * 0x1000000) - (G * 0x10000) - (B * 0x100)
    canvas:attrColor(R, G, B, A)
end

local function clear(std, engine, canvas, tint)
    color(std, engine, canvas, tint)
    local x = engine.offset_x
    local y = engine.offset_y
    local width = engine.current.data.width
    local height = engine.current.data.height
    canvas:drawRect('fill', x, y, width, height)
end

local function rect(std, engine, canvas, mode, pos_x, pos_y, width, height)
    local x = engine.offset_x + pos_x
    local y = engine.offset_y + pos_y
    canvas:drawRect(mode == 0 and 'fill' or 'frame', x, y, width, height)
end

local function text(std, engine, canvas, pos_x, pos_y, text)
    if pos_x and pos_y then
        local x = engine.offset_x + pos_x
        local y = engine.offset_y + pos_y
        canvas:drawText(x, y, text)
    end
    return canvas:measureText(text or pos_x)
end

local function tui_text(std, engine, canvas, pos_x, pos_y, size, text)
    local hem = engine.current.data.width / 80
    local vem = engine.current.data.height / 24
    local x = engine.offset_x + (pos_x * hem)
    local y = engine.offset_y + (pos_y * vem)
    local font_size = hem * size

    canvas:attrFont(current_font_name, font_size)
    canvas:drawText(x, y, text)
    canvas:attrFont(current_font_name, current_font_size)
end 

local function font(std, engine, canvas, name, size)
    if type(name) == 'number' and not size then
        size = name
        name = current_font_name
    end
    current_font_name = name
    current_font_size = size
    canvas:attrFont(name, size)
end

local function line(std, engine, canvas, x1, y1, x2, y2)
    local ox = engine.offset_x 
    local oy = engine.offset_y
    local px1 = ox + x1
    local py1 = oy + y1
    local px2 = ox + x2
    local py2 = oy + y2
    canvas:drawLine(px1, py1, px2, py2)
end

local function image(std, engine, canvas, src, x, y)
    local image = std.mem.cache('image'..src, function()
        return canvas:new('../assets/'..src)
    end)
    canvas:compose(x, y, image)
end

local function install(std, engine)
    std = std or {}
    std.draw = std.draw or {}

    std.draw.image = util_decorator.prefix3(std, engine, engine.canvas, image)
    std.draw.clear = util_decorator.prefix3(std, engine, engine.canvas, clear)
    std.draw.color = util_decorator.prefix3(std, engine, engine.canvas, color)
    std.draw.rect = util_decorator.prefix3(std, engine, engine.canvas, rect)
    std.draw.text = util_decorator.prefix3(std, engine, engine.canvas, text)
    std.draw.font = util_decorator.prefix3(std, engine, engine.canvas, font)
    std.draw.line = util_decorator.prefix3(std, engine, engine.canvas, line)
    std.draw.tui_text = util_decorator.prefix3(std, engine, engine.canvas, tui_text)

    return {
        draw=std.draw
    }
end

local P = {
    event_bus = event_bus,
    install = install
}

return P
