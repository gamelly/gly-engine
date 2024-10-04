local os = require('os')
local zeebo_module = require('src/lib/engine/module')
local engine_fps = require('src/lib/engine/fps')
local engine_game = require('src/lib/engine/game')
local engine_math = require('src/lib/engine/math')
local engine_draw_poly = require('src/lib/engine/draw_poly')
local engine_draw = require('src/engine/core/love/draw')
local engine_loop = require('src/engine/core/love/loop')
local engine_color = require('src/lib/object/color')
local engine_keys = require('src/engine/core/nintendo_wii/keys')
local game = require('src/lib/object/game')
local std = require('src/lib/object/std')

function love.load(args)
    local w, h = love.graphics.getDimensions()
    local application = zeebo_module.loadgame()
    local polygons = {
        repeats={true, true},
        line=love.graphics.line
    }

    if not application then
        error('game not found!')
    end

    zeebo_module.require(std, game, application)
        :package('@fps', engine_fps)
        :package('@game', engine_game, love.event.quit)
        :package('@math', engine_math)
        :package('@draw', engine_draw)
        :package('@keys', engine_keys)
        :package('@loop', engine_loop)
        :package('@color', engine_color)
        :package('@draw.poly', engine_draw_poly, polygons)
        :package('load', zeebo_module.load)
        :package('math', engine_math.clib)
        :package('math.random', engine_math.clib_random)
        :run()

    game.width, game.height = w, h
    game.fps_max = application.config and application.config.fps_max or 100
    game.fps_show = application.config and application.config.fps_show or 0
    application.callbacks.init(std, game)
end
