local version = require('src/version')
local zeebo_module = require('src/lib/common/module')
--
local engine_encoder = require('src/lib/engine/api/encoder')
local engine_game = require('src/lib/engine/api/game')
local engine_hash = require('src/lib/engine/api/hash')
local engine_http = require('src/lib/engine/api/http')
local engine_i18n = require('src/lib/engine/api/i18n')
local engine_key = require('src/lib/engine/api/key')
local engine_math = require('src/lib/engine/api/math')
local engine_draw_fps = require('src/lib/engine/draw/fps')
local engine_draw_poly = require('src/lib/engine/draw/poly')
local engine_raw_memory = require('src/lib/engine/raw/memory')
--
local application_default = require('src/lib/object/root')
local color = require('src/lib/object/color')
local std = require('src/lib/object/std')
--
local application = application_default
local engine = {
    keyboard = function(a, b, c, d) end,
    current = application_default,
    root = application_default
}

function native_callback_loop(dt)
    std.milis = std.milis + dt
    std.delta = dt
    application.callbacks.loop(std, application.data)
end

function native_callback_draw()
    native_draw_start()
    application.callbacks.draw(std, application.data)
    native_draw_flush()
end

function native_callback_resize(width, height)
    application.data.width = width
    application.data.height = height
    std.game.width = width
    std.game.height = height
end

function native_callback_keyboard(key, value)
    engine.keyboard(std, engine, key, value)
end

function native_callback_init(width, height, game_lua)
    application = zeebo_module.loadgame(game_lua)

    if application then
        application.data.width = width
        application.data.height = height
        std.game.width = width
        std.game.height = height
    end
    
    std.bus = {
        emit=function() end,
        emit_next=function() end,
        listen=function() end,
        listen_std_engine=function() end
    }

    std.draw.color=native_draw_color
    std.draw.font=native_draw_font
    std.draw.text=native_draw_text
    std.draw.rect=native_draw_rect
    std.draw.line=native_draw_line
    std.draw.image=native_draw_image
    std.draw.clear=function(tint)
        native_draw_clear(tint, 0, 0, application.data.width, application.data.height)
    end
    std.draw.tui_text=function(x, y, s, text)
        native_draw_text_tui(x, y, 0, 0, application.data.width, application.data.height, s, text)
    end

    zeebo_module.require(std, application, engine)
        :package('@memory', engine_raw_memory)
        :package('@game', engine_game, native_dict_game)
        :package('@math', engine_math)
        :package('@key', engine_key, {})
        :package('@draw.fps', engine_draw_fps)
        :package('@draw.poly', engine_draw_poly, native_dict_poly)
        :package('@color', color)
        :package('math', engine_math.clib)
        :package('math.random', engine_math.clib_random)
        :package('http', engine_http, native_dict_http)
        :package('json', engine_encoder, native_dict_json)
        :package('xml', engine_encoder, native_dict_xml)
        :package('i18n', engine_i18n, native_get_system_lang)
        :package('hash', engine_hash, native_dict_secret)
        :run()


    application.data.width, std.game.width = width, width
    application.data.height, std.game.height = height, height

    std.game.title(application.meta.title..' - '..application.meta.version)

    engine.root = application
    engine.current = application

    application.callbacks.init(std, application.data)
end

local P = {
    meta={
        title='gly-engine-lite',
        author='RodrigoDornelles',
        description='native lite',
        version=version
    }
}

return P
