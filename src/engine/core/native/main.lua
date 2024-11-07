local zeebo_module = require('src/lib/common/module')
--
local engine_encoder = require('src/lib/engine/api/encoder')
local engine_game = require('src/lib/engine/api/game')
local engine_hash = require('src/lib/engine/api/hash')
local engine_http = require('src/lib/engine/api/http')
local engine_i18n = require('src/lib/engine/api/i18n')
local engine_key = require('src/lib/engine/api/key')
local engine_math = require('src/lib/engine/api/math')
local engine_draw_ui = require('src/lib/engine/draw/ui')
local engine_draw_fps = require('src/lib/engine/draw/fps')
local engine_draw_poly = require('src/lib/engine/draw/poly')
local engine_raw_bus = require('src/lib/engine/raw/bus')
local engine_raw_node = require('src/lib/engine/raw/node')
local engine_raw_memory = require('src/lib/engine/raw/memory')
--
local application_default = require('src/lib/object/root')
local color = require('src/lib/object/color')
local std = require('src/lib/object/std')
--
local application = application_default
local engine = {
    current = application_default,
    root = application_default,
    offset_x = 0,
    offset_y = 0
}

--! @defgroup std
--! @{
--! @defgroup draw
--! @{

--! @short std.draw.clear
local function clear(tint)
    local x, y = engine.offset_x, engine.offset_y
    local width, height = engine.current.data.width, engine.current.data.height
    native_draw_clear(tint, x, y, width, height)
end

--! @short std.draw.rect
local function rect(mode, pos_x, pos_y, width, height)
    local ox, oy = engine.offset_x, engine.offset_y
    native_draw_rect(mode, pos_x + ox, pos_y + oy, width, height)
end

--! @short std.draw.tui_text
local function tui_text(pos_x, pos_y, size, text)
    local ox, oy = engine.offset_x, engine.offset_y
    local width, height = engine.current.data.width, engine.current.data.height
    native_draw_text_tui(pos_x, pos_y, ox, oy, width, height, size, text)
end

--! @short std.draw.text
local function text(pos_x, pos_y, text)
    local ox, oy = engine.offset_x, engine.offset_y
    if pos_x and pos_y then
        return native_draw_text(pos_x + ox, pos_y + oy, text)
    end
    return native_draw_text(pos_x)
end

--! @short std.draw.line
local function line(x1, y1, x2, y2)
    local ox, oy = engine.offset_x, engine.offset_y
    native_draw_line(x1 + ox, y1 + oy, x2 + ox, y2 + oy)
end

--! @short std.draw.image
local function image(src, pos_x, pos_y)
    local x = engine.offset_x + (pos_x or 0)
    local y = engine.offset_y + (pos_y or 0)
    native_draw_image(src, x, y)
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
        :package('@bus', engine_raw_bus)
        :package('@node', engine_raw_node)
        :package('@memory', engine_raw_memory)
        :package('@game', engine_game, native_dict_game)
        :package('@math', engine_math)
        :package('@key', engine_key, {})
        :package('@draw.ui', engine_draw_ui)
        :package('@draw.fps', engine_draw_fps)
        :package('@draw.poly', engine_draw_poly, native_dict_poly)
        :package('@color', color)
        :package('math', engine_math.clib)
        :package('math.random', engine_math.clib_random)
        :package('http', engine_http, native_dict_http)
        :package('json', engine_encoder, native_dict_json)
        :package('xml', engine_encoder, native_dict_xml)
        :package('i18n', engine_i18n, native_get_system_lang)
        :package('hash', engine_hash, {'native'})
        :run()

    application.data.width, std.game.width = width, width
    application.data.height, std.game.height = height, height

    std.node.spawn(application)
    std.game.title(application.meta.title..' - '..application.meta.version)

    engine.root = application
    engine.current = application

    std.bus.emit_next('load')
    std.bus.emit_next('init')
end

local P = {
    meta={
        title='gly-engine',
        author='RodrigoDornelles',
        description='native core',
        version='0.0.11'
    }
}

return P
