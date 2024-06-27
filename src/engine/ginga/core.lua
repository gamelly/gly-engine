local game = require('game')
local math = require('lib_math')
local canvas = canvas
local event = event
local game_obj = {}
local std = {draw={},key={press={}},game={}}
local fixture190 = ''
_ENV = nil

local function std_draw_clear(color)
    canvas:attrColor(color)
    canvas:drawRect('fill', 0, 0, game_obj.witdh, game_obj.height)
end

local function std_draw_color(color)
    canvas:attrColor(color)
end

local function std_draw_rect(a,b,c,d,e,f)
    if f and canvas.drawRoundRect then
        canvas:drawRoundRect(a,b,c,d,e,f)
        return
    end
    canvas:drawRect(a,b,c,d,e)
end

local function std_draw_text(a,b,c)
    canvas:drawText(a,b,c)
end

local function std_draw_font(a,b)
    canvas:attrFont(a,b)
end

local function std_draw_poly(mode, verts, x, y, size, angle)
    local index = 1
    local radius = 10
    size = size or 1
    while index < #verts do
        radius = radius + verts[index]
        index = index + 1
    end
    radius = radius * size / #verts
    canvas:drawEllipse('fill', x, y, radius, radius)
end

local function std_game_reset()
    if game.callbacks.exit then
        game.callbacks.exit(std, game_obj)
    end
    if game.callbacks.init then
        game.callbacks.init(std, game_obj)
    end
end

local function event_loop(evt)
    if evt.class ~= 'key' then return end

    -- https://github.com/TeleMidia/ginga/issues/190
    if #fixture190 == 0 and evt.key ~= 'ENTER' then
        fixture190 = evt.type
    end

    if fixture190 == evt.type then
        if evt.key == 'CURSOR_UP' then
            std.key.press.up = 1
        end
        if evt.key == 'CURSOR_DOWN' then
            std.key.press.down = 1
        end
    else
        if evt.key == 'CURSOR_UP' then
            std.key.press.up = 0
        end
        if evt.key == 'CURSOR_DOWN' then
            std.key.press.down = 0
        end
    end
end

local function fixed_loop()
    game_obj.milis = event.uptime()
    game.callbacks.loop(std, game_obj)
    canvas:attrColor(0, 0, 0, 0)
    canvas:clear()
    game.callbacks.draw(std, game_obj)
    canvas:flush()
    event.timer(1, fixed_loop)
end

local function setup(evt)
    if evt.class ~= 'ncl' or evt.action ~= 'start' then return end
    local w, h = canvas:attrSize()
    std.math=math
    std.draw.clear=std_draw_clear
    std.draw.color=std_draw_color
    std.draw.rect=std_draw_rect
    std.draw.text=std_draw_text
    std.draw.font=std_draw_font
    std.draw.poly=std_draw_poly
    std.key.press.up=0
    std.key.press.down=0
    std.key.press.left=0
    std.key.press.right=0
    std.game.reset=std_game_reset
    game_obj.witdh=w
    game_obj.height=h
    game_obj.milis=0
    game.callbacks.init(std, game_obj)
    event.register(event_loop)
    event.timer(1, fixed_loop)
    event.unregister(setup)
end

event.register(setup)
