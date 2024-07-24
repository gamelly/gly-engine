local zeebo_module = require('src/lib/engine/module')
local engine_fps = require('src/lib/engine/fps')
local engine_math = require('src/lib/engine/math')
local engine_color = require('src/lib/object/color')
local engine_draw = require('src/engine/core/ginga/draw')
local engine_ginga = require('src/engine/core/ginga/event')
local engine_draw_poly = require('src/lib/engine/draw_poly')
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

local function install(evt)
    if evt.class ~= 'ncl' or evt.action ~= 'start' then return end
    local application = zeebo_module.loadgame()
    local polygons = {
        repeats={true, true},
        line=canvas.drawLine,
        object=canvas
    }
    local ginga = {
        canvas=canvas,
        event=event
    }

    --engine_draw_poly.install(std, game, application, polygons)
    zeebo_module.require(std, game, application)
        :package('@fps', engine_fps)
        :package('@math', engine_math)
        :package('@color', engine_color)
        :package('@draw', engine_draw, ginga)
        :package('@ginga', engine_ginga, ginga)
        :package('@draw_poly', engine_draw_poly, polygons)
        :package('math', engine_math.clib)
        :package('random', engine_math.clib_random)
        :run()
    
    game.width, game.height = ginga.canvas:attrSize()
    game.fps_max = application.config and application.config.fps_max or 100
    game.fps_show = application.config and application.config.fps_show or 0
    application.callbacks.init(std, game)
    ginga.event.unregister(install)
end

event.register(install)
