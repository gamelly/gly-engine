local function decorator_line(func_draw_line)
    return function(mode, verts)
        local index = 4
        while index <= #verts do
            func_draw_line(verts[index - 3], verts[index - 2], verts[index - 1], verts[index])
            index = index + 2
        end
        if mode <= 1 then 
            func_draw_line(verts[1], verts[2], verts[#verts -1], verts[#verts])
        end
    end
end

local function decorator_poly(func_draw_poly, std, modes)    
    return function (engine_mode, verts, x, y, scale, angle, ox, oy)
        if #verts < 6 or #verts % 2 ~= 0 then return end
        local mode = modes and modes[engine_mode + 1] or engine_mode
        local rotated = std.math.cos and angle and angle ~= 0
        ox = ox or 0
        oy = oy or ox or 0
        
        if x and y and not rotated then
            local index = 1
            local verts2 = {}
            scale = scale or 1

            while index <= #verts do
                if index % 2 ~= 0 then
                    verts2[index] = x + (verts[index] * scale)
                else
                    verts2[index] = y + (verts[index] * scale)
                end
                index = index + 1
            end
            func_draw_poly(mode, verts2)
        elseif x and y then
            local index = 1
            local verts2 = {}
            while index < #verts do
                local px = verts[index]
                local py = verts[index + 1]
                local xx = x + ((ox - px) * -scale * std.math.cos(angle)) - ((ox - py) * -scale * std.math.sin(angle))
                local yy = y + ((oy - px) * -scale * std.math.sin(angle)) + ((oy - py) * -scale * std.math.cos(angle))
                verts2[index] = xx
                verts2[index + 1] = yy
                index = index + 2
            end
            func_draw_poly(mode, verts2)
        else
            func_draw_poly(mode, verts)
        end
    end
end

local function install(std, game, application, poly)
    local draw_poly = poly.poly
    local draw_line = poly.line
    if poly.object and draw_line then
        draw_line = function(a, b, c, d)
            poly.line(poly.object, a, b, c, d)
        end
    end
    if poly.object and draw_poly then
        draw_poly = function(a, b)
            poly.line(poly.object, a, b)
        end
    end
    if not draw_poly then
        draw_poly = decorator_line(draw_line)
    end
    std = std or {}
    std.draw = std.draw or {}
    std.draw.poly = decorator_poly(draw_poly, std, poly.modes)
    return {poly=std.draw.poly}
end

local P = {
    install=install
}

return P
