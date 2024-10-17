local util_decorator = require('src/lib/util/decorator')

local modes = {
    [0] = 'fill',
    [1] = 'line'
}

local function color(std, game, application, tint)
    local R = bit.band(bit.rshift(tint, 24), 0xFF)/255
    local G = bit.band(bit.rshift(tint, 16), 0xFF)/255
    local B = bit.band(bit.rshift(tint, 8), 0xFF)/255
    local A = bit.band(bit.rshift(tint, 0), 0xFF)/255
    love.graphics.setColor(R, G, B, A)
end

local function clear(std, game, application, tint)
    color(nil, nil, nil, tint)
    love.graphics.rectangle(modes[0], 0, 0, game.width, game.height)
end

local function rect(std, game, application, mode, x, y, width, height)
    love.graphics.rectangle(modes[mode], x, y, width, height)
end

local function text(std, game, application, x, y, text)
    local font = love.graphics.getFont()
    local t = text and tostring(text) or tostring(x)
    local n = select(2, t:gsub('\n', '')) + 1
    local w = font:getWidth(t)
    local h = (font:getHeight('A') * n) + (font:getLineHeight() * n)
    if x and y then
        love.graphics.print(t, x, y)
    end
    return w, h
end

local function line(std, game, application, x1, y1, x2, y2)
    love.graphics.line(x1, y1, x2, y2)
end

local function triangle(mode, x1, y1, x2, y2, x3, y3)
    love.graphics.line(x1, y1, x2, y2)
    love.graphics.line(x2, y2, x3, y3)
    if mode <= 1 then
        love.graphics.line(x1, y1, x3, y3)
    end
end

local function font(std, game, application, name, size)
    if not size and type(name) == 'number' then
        size = name
        name = 'Tiresias'
    end
    local f = std.mem.cache('font_'..name..tostring(size), function()
        return love.graphics.newFont(size)
    end)
    love.graphics.setFont(f)
end

local function image(std, game, application, src, x, y)
    local r, g, b, a = love.graphics.getColor()
    local image = std.mem.cache('image'..src, function()
        return love.graphics.newImage(src)
    end)
    love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
    love.graphics.draw(image, x, y)
    love.graphics.setColor(r, g, b, a) 
end

local function event_bus(std, game, application)
    std.bus.listen_std('post_draw', std.bus.trigger('draw_tui'))
end

local function install(std, game, application)
    application.callbacks.draw = application.callbacks.draw or function() end

    std.draw.image = util_decorator.prefix3(std, game, application, image)
    std.draw.clear = util_decorator.prefix3(std, game, application, clear)
    std.draw.color = util_decorator.prefix3(std, game, application, color)
    std.draw.rect = util_decorator.prefix3(std, game, application, rect)
    std.draw.text = util_decorator.prefix3(std, game, application, text)
    std.draw.font = util_decorator.prefix3(std, game, application, font)
    std.draw.line = util_decorator.prefix3(std, game, application, line)
    std.draw.tui_text = util_decorator.prefix3(std, game, application, text)

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
