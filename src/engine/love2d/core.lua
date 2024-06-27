local os = require('os')
local game = require('game')
local math = require('lib_math')
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
        white = {1, 1, 1}
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

local function std_draw_poly(mode, verts, x, y, scale, angle)
    if x and y and angle == nil then
        local index = 0
        local verts2 = {}
        scale = scale or 1

        while index < #verts do
            if index % 2 ~= 0 then
                verts2[index] = x + (verts[index] * scale)
            else
                verts2[index] = y + (verts[index] * scale)
            end
            index = index + 1
        end
        love.graphics.polygon(mode, verts2)
        return
    end

    love.graphics.polygon(mode, verts)
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
    game_obj.dt = 16
    game_obj.milis = love.timer.getTime() * 1000
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
    std.draw.poly=std_draw_poly
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
