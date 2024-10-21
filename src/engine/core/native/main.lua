local zeebo_module = require('src/lib/engine/raw/module')
--
local lib_api_encoder = require('src/lib/engine/api/encoder')
local lib_api_game = require('src/lib/engine/api/game')
local lib_api_hash = require('src/lib/engine/api/hash')
local lib_api_http = require('src/lib/engine/api/http')
local lib_api_i18n = require('src/lib/engine/api/i18n')
local lib_api_key = require('src/lib/engine/api/key')
local lib_api_math = require('src/lib/engine/api/math')
local lib_draw_fps = require('src/lib/engine/draw/fps')
local lib_draw_poly = require('src/lib/engine/draw/poly')
local lib_raw_bus = require('src/lib/engine/raw/bus')
local lib_raw_memory = require('src/lib/engine/raw/memory')
--
local color = require('src/lib/object/color')
local std = require('src/lib/object/std')
--
local application = {}
local engine = {}

--! @defgroup std
--! @{
--! @defgroup draw
--! @{

--! @short std.draw.clear
local function clear(tint)
    local x, y = engine.current.config.offset_x, engine.current.config.offset_y
    local width, height = engine.current.data.width, engine.current.data.height
    native_draw_clear(tint, x, y, width, height)
end

--! @short std.draw.rect
local function rect(mode, pos_x, pos_y, width, height)
    local ox, oy = engine.current.config.offset_x, engine.current.config.offset_y
    native_draw_rect(mode, pos_x + ox, pos_y + oy, width, height)
end

--! @short std.draw.tui_text
local function tui_text(pos_x, pos_y, size, text)
    local ox, oy = engine.current.config.offset_x, engine.current.config.offset_y
    local width, height = engine.current.data.width, engine.current.data.height
    native_draw_text_tui(pos_x, pos_y, ox, oy, width, height, size, text)
end

--! @short std.draw.text
local function text(pos_x, pos_y, text)
    local ox, oy = engine.current.config.offset_x, engine.current.config.offset_y
    if pos_x and pos_y then
        return native_draw_text(pos_x + ox, pos_y + oy, text)
    end
    return native_draw_text(pos_x)
end

--! @short std.draw.line
local function line(x1, y1, x2, y2)
    local ox, oy = engine.current.config.offset_x, engine.current.config.offset_y
    native_draw_line(x1 + ox, y1 + oy, x2 + ox, y2 + oy)
end

--! @short std.draw.image
local function image(src, pos_x, pos_y)
    local ox, oy = engine.current.config.offset_x, engine.current.config.offset_y
    native_draw_text_tui(src, pos_x + ox, pos_y + oy)
end

--! @}
--! @}

function native_callback_loop(dt)
    std.milis = std.milis + dt
    std.delta = dt
    std.bus.emit('loop')
end

function native_callback_draw()
    native_draw_start()
    std.bus.emit('draw')
    native_draw_flush()
end

function native_callback_resize(width, height)
    engine.root.data.width = width
    engine.root.data.height = height
    std.game.width = width
    std.game.height = height
    std.bus.emit('resize', width, height)
end

function native_callback_keyboard(key, value)
    std.bus.emit('rkey', key, value)
end

function native_callback_init(width, height, game_lua)
    application = zeebo_module.loadgame(game_lua)

    if application then
        application.data.width = width
        application.data.height = height
        std.game.width = width
        std.game.height = height
    end

    std.draw.color=native_draw_color
    std.draw.font=native_draw_font
    std.draw.clear=clear
    std.draw.text=text
    std.draw.tui_text=tui_text
    std.draw.rect=rect
    std.draw.line=line
    std.draw.image=image
    
    zeebo_module.require(std, application, engine)
        :package('@bus', lib_raw_bus)
        :package('@memory', lib_raw_memory)
        :package('@module', zeebo_module.lib)
        :package('@game', lib_api_game, {})
        :package('@math', lib_api_math)
        :package('@key', lib_api_key, {})
        :package('@draw.poly', lib_draw_poly, native_dict_poly)
        :package('@draw.fps', lib_draw_fps)
        :package('@color', color)
        :package('math', lib_api_math.clib)
        :package('math.random', lib_api_math.clib_random)
        :package('http', lib_api_http, cfg_http_curl_love)
        :package('json', lib_api_encoder, native_dict_json)
        :package('xml', lib_api_encoder, native_dict_xml)
        :package('i18n', lib_api_i18n, native_get_system_lang)
        :run()

    engine.root = application
    engine.current = application

    std.bus.spawn(application)
    std.bus.emit_next('load')
    std.bus.emit_next('init')
end

local P = {
    meta={
        title='gly-engine',
        author='RodrigoDornelles',
        description='native core',
        version='0.0.8'
    }
}

return P
