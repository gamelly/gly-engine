local zeebo_module = require('src/lib/common/module')
--
local core_draw = require('ee/engine/core/ginga/draw')
local core_text = require('ee/engine/core/ginga/text')
local core_keys = require('ee/engine/core/ginga/keys')
--
local engine_encoder = require('src/lib/engine/api/encoder')
local engine_game = require('src/lib/engine/api/app')
local engine_hash = require('src/lib/engine/api/hash')
local engine_http = require('src/lib/engine/api/http')
local engine_i18n = require('src/lib/engine/api/i18n')
local engine_keys = require('src/lib/engine/api/key')
local engine_math = require('src/lib/engine/api/math')
local engine_array = require('src/lib/engine/api/array')
local engine_draw_ui = require('src/lib/engine/draw/ui')
local engine_draw_fps = require('src/lib/engine/draw/fps')
local engine_draw_text = require('src/lib/engine/draw/text')
local engine_draw_poly = require('src/lib/engine/draw/poly')
local engine_bus = require('src/lib/engine/raw/bus')
local engine_fps = require('src/lib/engine/raw/fps')
local engine_node = require('src/lib/engine/raw/node')
local engine_memory = require('src/lib/engine/raw/memory')
--
local cfg_json_rxi = require('third_party/json/rxi')
local cfg_http_ginga = require('ee/lib/protocol/http_ginga')
--
local application_default = require('src/lib/object/root')
local color = require('src/lib/object/color')
local std = require('src/lib/object/std')
--
local application = application_default

--! @short nclua:canvas
--! @li <http://www.telemidia.puc-rio.br/~francisco/nclua/referencia/canvas.html>
local canvas = canvas

--! @short nclua:event
--! @li <http://www.telemidia.puc-rio.br/~francisco/nclua/referencia/event.html>
local event = event

--! @field canvas <http://www.telemidia.puc-rio.br/~francisco/nclua/referencia/canvas.html>
--! @field event <http://www.telemidia.puc-rio.br/~francisco/nclua/referencia/event.html>
local engine = {
    current = application_default,
    root = application_default,
    canvas = canvas,
    event = event,
    offset_x = 0,
    offset_y = 0,
    delay = 1,
    fps = 0
}

--! @short clear ENV
--! @brief GINGA?
_ENV = nil

local cfg_app = {

}

local cfg_poly = {
    repeats={true, true},
    line=canvas.drawLine,
    object=canvas
}

local cfg_fps_control = {
    list={100, 60, 30, 20, 15, 10},
    time={1, 10, 30, 40, 60, 90},
    uptime=event.uptime
}

local cfg_text = {
    font_previous = core_text.font_previous
}

local system_language = function()
    return 'pt-BR'
end

local function register_event_loop()
    event.register(std.bus.trigger('ginga'))
end

local function register_fixed_loop()
    local tick = nil
    local loop = std.bus.trigger('loop')
    local draw = std.bus.trigger('draw')    
    tick = function()
        loop()
        canvas:attrColor(0, 0, 0, 0)
        canvas:clear()
        draw()
        canvas:flush()
        event.timer(engine.delay, tick)
    end

    event.timer(engine.delay, tick)
end

local function install(evt, gamefile)
    if evt.class ~= 'ncl' or evt.action ~= 'start' then return end

    application = zeebo_module.loadgame(gamefile)

    zeebo_module.require(std, application, engine)
        :package('@bus', engine_bus)
        :package('@node', engine_node)
        :package('@fps', engine_fps, cfg_fps_control)
        :package('@memory', engine_memory)
        :package('@game', engine_game, cfg_app)
        :package('@math', engine_math)
        :package('@array', engine_array)
        :package('@keys1', engine_keys)
        :package('@keys2', core_keys)
        :package('@draw', core_draw)
        :package('@draw.text', core_text)
        :package('@draw.text2', engine_draw_text, cfg_text)
        :package('@draw.ui', engine_draw_ui)
        :package('@draw.fps', engine_draw_fps)
        :package('@draw.poly', engine_draw_poly, cfg_poly)
        :package('@color', color)
        :package('math', engine_math.clib)
        :package('hash', engine_hash, {'ginga'})
        :package('math.random', engine_math.clib_random)
        :package('json', engine_encoder, cfg_json_rxi)
        :package('http', engine_http, cfg_http_ginga)
        :package('i18n', engine_i18n, system_language)
        :run()

    application.data.width, application.data.height = canvas:attrSize()
    std.app.width, std.app.height = application.data.width, application.data.height

    std.node.spawn(application)

    engine.root = application
    engine.current = application

    register_event_loop()
    register_fixed_loop()

    std.bus.emit_next('load')
    std.bus.emit_next('init')

    event.unregister(install)
end

event.register(install)
return install
