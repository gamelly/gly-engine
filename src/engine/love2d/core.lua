local os = require('os')
local game = require('game')
local math = require('lib_math')
local decorators = require('decorators')
local game_obj = {}
local std = {draw={},key={press={}},game={}}
local started = false

local function std_draw_clear(color)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, game_obj.width, game_obj.height)
end

local function std_draw_color(color)
    local colors = {
        black = {0, 0, 0},
        white = {1, 1, 1},
        yellow = {1, 1, 0}
    }
    love.graphics.setColor(colors[color][1], colors[color][2], colors[color][3])
end

local function std_draw_rect(a,b,c,d,e,f)
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

function love.update(dt)
    game_obj.dt = dt * 1000
    game_obj.milis = love.timer.getTime() * 1000
    game_obj.fps = love.timer.getFPS()
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
    std.draw.clear=std_draw_clear
    std.draw.color=std_draw_color
    std.draw.rect=std_draw_rect
    std.draw.text=std_draw_text
    std.draw.font=std_draw_font
    std.draw.poly=decorators.poly(0, love.graphics.polygon)
    std.key.press.up=0
    std.key.press.down=0
    std.key.press.left=0
    std.key.press.right=0
    std.game.reset=std_game_reset
    game_obj.width=w
    game_obj.height=h
    game_obj.dt = 0
    love.window.setTitle(game.meta.title..' - '..game.meta.version)
    game.callbacks.init(std, game_obj)
end
