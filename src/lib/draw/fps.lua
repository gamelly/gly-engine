local function fps(self, show, x, y)
    local s = 4
    self.std.draw.color(0xFFFF00FF)
    if show >= 1 then
        self.std.draw.rect(0, x, y, 40, 24)
    end
    if show >= 2 then
        self.std.draw.rect(0, x + 48, y, 40, 24)
    end
    if show >= 3 then
        self.std.draw.rect(0, x + 96, y, 40, 24)
    end
    self.std.draw.color(0x000000FF)
    self.std.draw.font('Tiresias', 16)
    if show >= 3 then
        local fps = self.std.math.floor and self.std.math.floor((1/self.game.dt) * 1000) or '--'
        self.std.draw.text(x + s, y, fps)
        s = s + 46
    end
    if show >= 1 then
        self.std.draw.text(x + s, y, self.game.fps)
        s = s + 46
    end
    if show >= 2 then
        self.std.draw.text(x + s, y, self.game.fps_max)
        s = s + 46
    end
end

local function install(std, game, application)
    std = std or {}    
    std.draw = std.draw or {}
    std.draw.fps = function(show, x, y)
        fps({std=std, game=game}, show, x, y)
    end

    local event_draw = function()
        if game.fps_show and game.fps_show > 0 then
            std.draw.fps(game.fps_show, 8, 8)
        end
    end

    return {
        event={draw=event_draw},
        std={draw={fps=std.draw.fps}}
    }
end

local P = {
    install=install
}

return P
