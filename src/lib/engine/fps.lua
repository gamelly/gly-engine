local function fps_counter(fps_limit, fps_obj, uptime)
    if uptime >= fps_obj.period + 1000 then
        fps_obj.period = uptime
        fps_obj.total = fps_obj.count
        fps_obj.count = 0

        if fps_obj.drop_count == 0 then
            return true
        end

        if fps_obj.total + fps_obj.drop_count > fps_limit then
            fps_obj.falls = 0
            return true
        end

        fps_obj.falls = fps_obj.falls + 1
        
        if fps_obj.drop_time < fps_obj.falls then
            fps_obj.falls = 0
            return false
        end
    end
    
    fps_obj.count = fps_obj.count + 1
    fps_obj.delta = uptime - fps_obj.passed
    fps_obj.passed = uptime

    return true
end

local function fps(std, game, show, x, y)
    std.draw.color(0xFFFF00FF)
    if show >= 1 then
        std.draw.rect(0, x, y, 40, 24)
    end
    if show >= 2 then
       std.draw.rect(0, x + 48, y, 40, 24)
    end
    std.draw.color(0x000000FF)
    std.draw.font('Tiresias', 16)
    if show >= 1 then
        std.draw.text(x + 2, y, game.fps_max)
    end
    if show >= 1 then
        std.draw.text(x + 50, y, game.fps)
    end
end

local function install(std, game, application)
    std = std or {}
    std.draw = std.draw or {}
    application = application or {}
    application.internal = application.internal or {}
    application.internal.fps_counter=fps_counter
    std.draw.fps = function(show, x, y)
        fps(std, game, show, x, y)
    end
    
    return {
        counter=fps_counter,
        draw=std.draw.fps
    }
end

local P = {
    install=install
}

return P
