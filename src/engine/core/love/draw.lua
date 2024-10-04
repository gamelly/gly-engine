local modes = {
    [true] = {
        [0] = true,
        [1] = false
    },
    [false] = {
        [0] = 'fill',
        [1] = 'line'
    }
}

local function color(c)
    local DIV = love.wiimote and 1 or 255
    local R = bit.band(bit.rshift(c, 24), 0xFF)/DIV
    local G = bit.band(bit.rshift(c, 16), 0xFF)/DIV
    local B = bit.band(bit.rshift(c, 8), 0xFF)/DIV
    local A = bit.band(bit.rshift(c, 0), 0xFF)/DIV
    love.graphics.setColor(R, G, B, A)
end

local function rect(a,b,c,d,e,f)
    love.graphics.rectangle(modes[love.wiimote ~= nil][a], b, c, d, e)
end

--! @todo support WII
local function text(x, y, text)
    if love.wiimote then return 32 end
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

local function line(x1, y1, x2, y2)
    love.graphics.line(x1, y1, x2, y2)
end

local function triangle(mode, x1, y1, x2, y2, x3, y3)
    love.graphics.line(x1, y1, x2, y2)
    love.graphics.line(x2, y2, x3, y3)
    if mode <= 1 then
        love.graphics.line(x1, y1, x3, y3)
    end
end

local function font(std, name, size)
    if not size and type(name) == 'number' then
        size = name
        name = 'Tiresias'
    end
    local f = std.mem.cache('font_'..name..tostring(size), function()
        return love.graphics.newFont(size)
    end)
    love.graphics.setFont(f)
end

local function image(std, src, x, y)
    local r, g, b, a = love.graphics.getColor()
    local image = std.mem.cache('image'..src, function()
        return love.graphics.newImage(src)
    end)
    love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
    love.graphics.draw(image, x, y)
    love.graphics.setColor(r, g, b, a) 
end

local function install(std, game, application)
    application.callbacks.draw = application.callbacks.draw or function() end

    -- pure love
    std.draw.color=color
    std.draw.rect=rect
    std.draw.text=text
    std.draw.line=line

    -- engine dependent
    std.draw.image=function(src, x, y) return image(std, src, x, y) end
    std.draw.font=function(name, size) return font(std, name, size) end

    std.draw.clear = function(c)
        color(c)
        love.graphics.rectangle(modes[love.wiimote ~= nil][0], 0, 0, game.width, game.height)
    end

    local event_draw = function()
        application.callbacks.draw(std, game)
    end

    return {
        event={draw=event_draw},
        std={draw=std.draw}
    }
end

local P = {
    install = install,
    triangle=triangle
}

return P
