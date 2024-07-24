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

local function text(x, y, text)
    if love.wiimote then return 32 end -- TODO support WII
    if x and y then
        love.graphics.print(text, x, y)
    end
    return love.graphics.getFont():getWidth(text or x)
end

local function line(x1, y1, x2, y2)
    love.graphics.line(x1, y1, x2, y2)
end

local function font(a,b)
    -- TODO: not must be called in update 
end

local function install(std, game, application)
    std = std or {}
    std.draw = std.draw or {}
    application.callbacks.draw = application.callbacks.draw or function() end
    
    std.draw.clear = function(c)
        color(c)
        love.graphics.rectangle(modes[love.wiimote ~= nil][0], 0, 0, game.width, game.height)
    end
    
    std.draw.color=color
    std.draw.rect=rect
    std.draw.text=text
    std.draw.line=line
    std.draw.font=font

    if love then
        love.draw = function()
            application.callbacks.draw(std, game)
        end
        love.resize = function(w, h)
            game.width, game.height = w, h
        end
    end

    return std.draw
end

local P = {
    install = install
}

return P
