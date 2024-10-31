local util_decorator = require('src/lib/util/decorator')

local modes = {
    [0] = 'fill',
    [1] = 'line'
}

local function color(std, engine, tint)
    local R = bit.band(bit.rshift(tint, 24), 0xFF)/255
    local G = bit.band(bit.rshift(tint, 16), 0xFF)/255
    local B = bit.band(bit.rshift(tint, 8), 0xFF)/255
    local A = bit.band(bit.rshift(tint, 0), 0xFF)/255
    love.graphics.setColor(R, G, B, A)
end

local function clear(std, engine, tint)
    color(nil, nil, tint)
    local x = engine.offset_x
    local y = engine.offset_y
    local width = engine.current.data.width
    local height = engine.current.data.height
    love.graphics.rectangle(modes[0], x, y, width, height)
end

local function rect(std, engine, mode, pos_x, pos_y, width, height)
    local x = engine.offset_x + pos_x
    local y = engine.offset_y + pos_y
    love.graphics.rectangle(modes[mode], x, y, width, height)
end

local function tui_text(std, engine, pos_x, pos_y, size, text)
    local hem = engine.current.data.width / 80
    local vem = engine.current.data.height / 24
    local x = engine.offset_x + (pos_x * hem)
    local y = engine.offset_y + (pos_y * vem)
    local font_size = hem * size

    local old_font = love.graphics.getFont()
    local new_font = std.mem.cache('font_tui'..tostring(font_size), function()
        return love.graphics.newFont(font_size)
    end)

    love.graphics.setFont(new_font)
    love.graphics.print(text, x, y)
    love.graphics.setFont(old_font)
end

local function text(std, engine, pos_x, pos_y, text)
    local font = love.graphics.getFont()
    local t = text and tostring(text) or tostring(pos_x)
    local n = select(2, t:gsub('\n', '')) + 1
    local w = font:getWidth(t)
    local h = (font:getHeight('A') * n) + (font:getLineHeight() * n)
    if pos_x and pos_y then
        local x = engine.offset_x + pos_x
        local y = engine.offset_y + pos_y
        love.graphics.print(t, x, y)
    end
    return w, h
end

local function line(std, engine, x1, y1, x2, y2)
    local ox = engine.offset_x 
    local oy = engine.offset_y
    local px1 = ox + x1
    local py1 = oy + y1
    local px2 = ox + x2
    local py2 = oy + y2
    love.graphics.line(px1, py1, px2, py2)
end

local function triangle(mode, x1, y1, x2, y2, x3, y3)
    love.graphics.line(x1, y1, x2, y2)
    love.graphics.line(x2, y2, x3, y3)
    if mode <= 1 then
        love.graphics.line(x1, y1, x3, y3)
    end
end

local function font(std, engine, name, size)
    if not size and type(name) == 'number' then
        size = name
        name = 'Tiresias'
    end
    local f = std.mem.cache('font_'..name..tostring(size), function()
        return love.graphics.newFont(size)
    end)
    love.graphics.setFont(f)
end

local function image(std, engine, src, x, y)
    local r, g, b, a = love.graphics.getColor()
    local image = std.mem.cache('image'..src, function()
        return love.graphics.newImage(src)
    end)
    love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
    love.graphics.draw(image, x, y)
    love.graphics.setColor(r, g, b, a) 
end

local function event_bus(std, engine)
    std.bus.listen('resize', function(w, h)
        engine.root.data.width = w
        engine.root.data.height = h
        std.game.width = w
        std.game.height = h
    end)
end

local function install(std, engine)
    std.draw.image = util_decorator.prefix2(std, engine, image)
    std.draw.clear = util_decorator.prefix2(std, engine, clear)
    std.draw.color = util_decorator.prefix2(std, engine, color)
    std.draw.rect = util_decorator.prefix2(std, engine, rect)
    std.draw.text = util_decorator.prefix2(std, engine, text)
    std.draw.font = util_decorator.prefix2(std, engine, font)
    std.draw.line = util_decorator.prefix2(std, engine, line)
    std.draw.tui_text = util_decorator.prefix2(std, engine, tui_text)

    return {
        draw=std.draw
    }
end

local P = {
    install = install,
    event_bus = event_bus,
    triangle = triangle
}

return P
