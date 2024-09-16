local zeebo_module = require('src/lib/engine/module')
local engine_encoder = require('src/lib/engine/encoder')
local engine_fps = require('src/lib/engine/fps')
local engine_math = require('src/lib/engine/math')
local engine_game = require('src/lib/engine/game')
local engine_http = require('src/lib/engine/http')
local engine_dialog = require('src/lib/engine/dialog')
local engine_color = require('src/lib/object/color')
local engine_keys = require('src/engine/core/ginga/keys')
local engine_loop = require('src/engine/core/ginga/loop')
local engine_draw = require('src/engine/core/ginga/draw')
local engine_draw_fps = require('src/lib/draw/fps')
local engine_draw_poly = require('src/lib/draw/poly')
local engine_draw_dialog = require('src/lib/draw/dialog')
local library_csv = require('src/third_party/csv/rodrigodornelles')
local library_json = require('src/third_party/json/rxi')
local protocol_http_ginga = require('src/lib/protocol/http_ginga')
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

local function register_event_loop(listener)
    event.register(listener('ginga'))
end

local function register_fixed_loop(listener)
    local tick = nil
    local loop = listener('loop')
    local draw = listener('draw')

    tick = function()
        local delay = application.internal.fps_controler(event.uptime())
        loop()
        canvas:attrColor(0, 0, 0, 0)
        canvas:clear()
        draw()
        canvas:flush()
        event.timer(delay, tick)
    end

    event.timer(1, tick)
end

local function install(evt, gamefile)
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

    application = zeebo_module.loadgame(gamefile)
    if not application then
        error('game not loaded!')
    end

    game.width, game.height = canvas:attrSize()
    game.fps_max = application.config and application.config.fps_max or 100
    game.fps_show = application.config and application.config.fps_show or 0

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
        :package('load', zeebo_module.load)
        :package('csv', engine_encoder, library_csv)
        :package('json', engine_encoder, library_json)
        :package('math', engine_math.clib)
        :package('random', engine_math.clib_random)
        :package('http', engine_http, protocol_http_ginga)
        :package('dialog', engine_dialog)
        :package('dialog.draw', engine_draw_dialog)
        :register(register_event_loop)
        :register(register_fixed_loop)
        :run()

    application.callbacks.init(std, game)
    event.unregister(install)
end

event.register(install)
return install
