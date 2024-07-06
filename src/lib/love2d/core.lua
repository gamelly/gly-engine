local os = require('os')
local application = require('game')
local zeebo_math = require('lib_math')
local decorators = require('decorators')
local zeebo_arg = require('args')
local game = require('src_object_game')
local std = require('src_object_std')
local key_bindings = {
    up='up',
    left='left',
    right='right',
    down='down',
    z='red',
    x='green',
    c='yellow',
    v='blue',
    ['return']='enter'
}

local function std_draw_clear(color)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, game.width, game.height)
end

local function std_draw_color(color)
    local colors = {
        black = {0, 0, 0},
        white = {1, 1, 1},
        yellow = {1, 1, 0},
        green = {0, 1, 0},
        red= {1, 0, 0}
    }
    love.graphics.setColor(colors[color][1], colors[color][2], colors[color][3])
end

local function std_draw_rect(a,b,c,d,e,f)
    love.graphics.rectangle(a, b, c, d, e)
end

local function std_draw_text(x, y, text)
    if x and y then
        love.graphics.print(text, x, y)
    end
    return love.graphics.getFont():getWidth(text or x)
end

local function std_draw_line(x1, y1, x2, y2)
    love.graphics.line(x1, y1, x2, y2)
end

local function std_draw_font(a,b)
    -- TODO: not must be called in update 
end

local function std_game_reset()
    if application.callbacks.exit then
        application.callbacks.exit(std, game)
    end
    if application.callbacks.init then
        application.callbacks.init(std, game)
    end
end

local function std_game_exit()
    if application.callbacks.exit then
        application.callbacks.exit(std, game)
    end
    love.event.quit()
end

function love.draw()
    application.callbacks.draw(std, game)
end

function love.update(dt)
    game.dt = dt * 1000
    game.milis = love.timer.getTime() * 1000
    game.fps = love.timer.getFPS()
    application.callbacks.loop(std, game)
end

function love.keypressed(key)
    if key_bindings[key] then
        std.key.press[key_bindings[key]] = 1
    end
end

function love.keyreleased(key)
    if key_bindings[key] then
        std.key.press[key_bindings[key]] = 0
    end
end

function love.resize(w, h)
    game.width = w
    game.height = h
end

function love.load(args)
    local screen = zeebo_arg.get(args, 'screen')
    local w, h = love.graphics.getDimensions()
    if screen then
        w, h = screen:match('(%d+)x(%d+)')
        w, h = tonumber(w), tonumber(h)
        love.window.setMode(w, h, {resizable=true})
    end
    std.math=zeebo_math
    std.math.random = love.math.random
    std.draw.clear=std_draw_clear
    std.draw.color=std_draw_color
    std.draw.rect=std_draw_rect
    std.draw.text=std_draw_text
    std.draw.font=std_draw_font
    std.draw.line=std_draw_line
    std.draw.poly=decorators.poly(0, love.graphics.polygon)
    std.game.reset=std_game_reset
    std.game.exit=std_game_exit
    game.width=w
    game.height=h
    love.window.setTitle(application.meta.title..' - '..application.meta.version)
    application.callbacks.init(std, game)
end
