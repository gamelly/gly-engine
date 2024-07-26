local zeebo_module = require('src/lib/engine/module')
local engine_csv = require('src/lib/engine/csv')
local engine_fps = require('src/lib/engine/fps')
local engine_math = require('src/lib/engine/math')
local engine_game = require('src/lib/engine/game')
local engine_http = require('src/lib/engine/http')
local engine_color = require('src/lib/object/color')
local engine_keys = require('src/engine/core/ginga/keys')
local engine_loop = require('src/engine/core/ginga/loop')
local engine_draw = require('src/engine/core/ginga/draw')
local engine_draw_fps = require('src/lib/engine/draw_fps')
local engine_draw_poly = require('src/lib/engine/draw_poly')
local protocol_curl = require('src/lib/protocol/http_curl')
local application = nil
local game = require('src/lib/object/game')
local std = require('src/lib/object/std')

--! @short nclua:canvas
--! @li <http://www.telemidia.puc-rio.br/~francisco/nclua/referencia/canvas.html>
local canvas = canvas

--! @short nclua:event
--! @li <http://www.telemidia.puc-rio.br/~francisco/nclua/referencia/event.html>
local event = event

--! @short clear ENV
--! @brief GINGA?
_ENV = nil

local function event_loop(evt)
    local index = 1
    while index <= #application.internal.event_loop do
        application.internal.event_loop[index](evt)
        index = index + 1
    end
end

local function fixed_loop()
    local delay = application.internal.fps_controler(event.uptime())
    local index = 1

    while index <= #application.internal.fixed_loop do
        application.internal.fixed_loop[index]()
        index = index + 1
    end

    event.timer(delay, fixed_loop)
end

local function install(evt)
    if evt.class ~= 'ncl' or evt.action ~= 'start' then return end
    local ginga = {
        canvas=canvas,
        event=event
    }
    local polygons = {
        repeats={true, true},
        line=canvas.drawLine,
        object=canvas
    }
    local config_fps = {
        list={100, 60, 30, 20, 15, 10},
        time={1, 10, 30, 40, 60, 90}
    }

    application = zeebo_module.loadgame()
    if not application then
        error('game not loaded!')
    end

    game.width, game.height = canvas:attrSize()
    game.fps_max = application.config and application.config.fps_max or 100
    game.fps_show = application.config and application.config.fps_show or 0
    application.internal = {
        event_loop={},
        fixed_loop={}
    }

    zeebo_module.require(std, game, application)
        :package('@fps', engine_fps, config_fps)
        :package('@math', engine_math)
        :package('@game', engine_game)
        :package('@color', engine_color)
        :package('@keys', engine_keys)
        :package('@loop', engine_loop)
        :package('@draw', engine_draw, ginga)
        :package('@draw_fps', engine_draw_fps)
        :package('@draw_poly', engine_draw_poly, polygons)
        :package('csv', engine_csv)
        :package('math', engine_math.clib)
        :package('random', engine_math.clib_random)
        --:package('http', engine_http, protocol_curl)
        :run()
    
    application.callbacks.init(std, game)
    event.timer(1, fixed_loop)
    event.register(event_loop)
    event.unregister(install)
end

event.register(install)
