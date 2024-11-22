local util_decorator = require('src/lib/util/decorator')

local function text_put(std, engine, size, pos_x, pos_y, text)
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

local function text_print(std, engine, pos_x, pos_y, text)
    local x = engine.offset_x + pos_x
    local y = engine.offset_y + pos_y
    love.graphics.print(text, x, y)
end

local function font_size(std, engine, size)
    local f = std.mem.cache('font_'..tostring(size), function()
        return love.graphics.newFont(size)
    end)
    love.graphics.setFont(f)
end

local function text_mensure(std, engine, text)
    local font = love.graphics.getFont()
    local t = tostring(text)
    local n = select(2, t:gsub('\n', '')) + 1
    local w = font:getWidth(t)
    local h = (font:getHeight('A') * n) + (font:getLineHeight() * n)
    return w, h
end

local function install(std, engine)
    std.text = std.text or {}
    std.text.put = util_decorator.prefix2(std, engine, text_put)
    std.text.print = util_decorator.prefix2(std, engine, text_print)
    std.text.font_size = util_decorator.prefix2(std, engine, font_size)
    std.text.font_name = util_decorator.prefix2(std, engine, function() end)
    std.text.font_default = util_decorator.prefix2(std, engine, function() end)
    std.text.mensure = util_decorator.prefix2(std, engine, text_mensure)
    std.text.print_ex = function(x, y, text, align)
        local w, h = text_mensure(std, engine, text)
        local aligns = {w, w/2, 0}
        text_print(std, engine, x - aligns[(align or 1) + 2], y, text)
        return w, h
    end
end

local P = {
    install = install
}

return P
