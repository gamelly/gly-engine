local game = require('game')
local math = require('game_math')
local game_obj = {}
local std = {draw={},key={press={}},game={}}
local started = false

local function std_draw_color(color)
    local colors = {
        black = {0, 0, 0},
        white = {1, 1, 1}
    }
    love.graphics.setColor(colors[color][1], colors[color][2], colors[color][3])
end

local function std_draw_rect(a,b,c,d,e)
    love.graphics.rectangle(a, b, c, d, e)
end

local function std_draw_text(a,b,c)
    love.graphics.print(c, a, b)
end

local function std_draw_font(a,b)
    -- TODO: not must be called in update 
end

local function std_game_reset()
    if game.callbacks.exit then
        game.callbacks.exit(std, game_obj)
    end
    if game.callbacks.init then
        game.callbacks.init(std, game_obj)
    end
end

function love.draw()
    game.callbacks.draw(std, game_obj)
end

function love.update()
    game.callbacks.loop(std, game_obj)
end

function love.keypressed(key)
    std.key.press[key] = 1
end

function love.keyreleased(key)
    std.key.press[key] = 0
end

function love.load()
    local w, h = love.graphics.getDimensions()
    std.math=math
    std.draw.color=std_draw_color
    std.draw.rect=std_draw_rect
    std.draw.text=std_draw_text
    std.draw.font=std_draw_font
    std.key.press.up=0
    std.key.press.down=0
    std.key.press.left=0
    std.key.press.right=0
    std.game.reset=std_game_reset
    std.game.witdh=w
    std.game.height=h
    game.callbacks.init(std, game_obj)
end
