local os = require('os')
local zeebo_math = require('src/lib/engine/math')
local zeebo_module = require('src/lib/engine/module')
local zeebo_draw = require('src/engine/core/love/draw')
local zeebo_keys = require('src/engine/core/love/keys')
local zeebo_loop = require('src/engine/core/love/loop')
local decorators = require('src/lib/engine/decorators')
local zeebo_args = require('src/lib/common/args')
local color = require('src/lib/object/color')
local game = require('src/lib/object/game')
local std = require('src/lib/object/std')

function love.load(args)
    local w, h = love.graphics.getDimensions()
    local screen = args and zeebo_args.get(args, 'screen')
    local game_title = zeebo_args.param(arg, {'screen'}, 2)
    local application = zeebo_module.loadgame(game_title)

    if not application then
        error('game not found!')
    end
    if screen then
        w, h = screen:match('(%d+)x(%d+)')
        w, h = tonumber(w), tonumber(h)
        love.window.setMode(w, h, {resizable=true})
    end
    color.install(std)
    zeebo_keys.install(std)
    zeebo_loop.install(std, game, application)
    zeebo_draw.install(std, game, application)
    zeebo_math.install(std)
    zeebo_math.clib_random.install(std)
    std.draw.poly=decorators.poly(0, love.graphics.polygon)
    game.width=w
    game.height=h
    love.window.setTitle(application.meta.title..' - '..application.meta.version)
    application.callbacks.init(std, game)
end
