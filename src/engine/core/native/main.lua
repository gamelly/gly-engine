local zeebo_module = require('src/lib/engine/module')
local engine_game = require('src/lib/engine/game')
local engine_math = require('src/lib/engine/math')
local engine_color = require('src/lib/object/color')
local engine_http = require('src/lib/engine/http')
local engine_encoder = require('src/lib/engine/encoder')
local engine_draw_fps = require('src/lib/draw/fps')
local engine_draw_poly = require('src/lib/draw/poly')
local engine_i18n = require('src/lib/engine/i18n')
local engine_memory = require('src/lib/engine/memory')
local library_csv = require('src/third_party/csv/rodrigodornelles')
local game = require('src/lib/object/game')
local std = require('src/lib/object/std')
local application = nil
local extraevents = {
    loop = function(dt) end,
    draw = function() end,
    keydown = function(key, value) end
}

function native_callback_loop(milis)
    game.milis = milis
    application.callbacks.loop(std, game)
    extraevents.loop(milis)
    return game.dt
end

function native_callback_draw()
    native_draw_start()
    application.callbacks.draw(std, game)
    extraevents.draw()
    native_draw_flush()
end

function native_callback_resize(width, height)
    game.width = width
    game.height = height
end

function native_callback_keyboard(key, value)
    std.key.press[key] = value
    extraevents.keydown(key, value)
end

function native_callback_init(width, height, game_lua)
    application = zeebo_module.loadgame(game_lua)

    std.draw.clear=native_draw_clear
    std.draw.color=native_draw_color
    std.draw.font=native_draw_font
    std.draw.text=native_draw_text
    std.draw.rect=native_draw_rect
    std.draw.line=native_draw_line
    std.draw.image=native_draw_image
    
    zeebo_module.require(std, game, application)
        :package('@game', engine_game)
        :package('@math', engine_math)
        :package('@color', engine_color)
        :package('@draw_fps', engine_draw_fps)
        :package('@draw_poly', engine_draw_poly, native_dict_poly)
        :package('load', zeebo_module.load)
        :package('math', engine_math.clib)
        :package('random', engine_math.clib_random)
        :package('http', engine_http, native_dict_http)
        :package('json', engine_encoder, native_dict_json)
        :package('xml', engine_encoder, native_dict_xml)
        :package('csv', engine_encoder, library_csv)
        :package('i18n', engine_i18n, native_get_system_lang)
        :register(function(listener)
            extraevents.loop = listener('loop')
            extraevents.draw = listener('draw')
            extraevents.keydown = listener('keydown')
        end)
        :run()

    game.width = width
    game.height = height
    game.fps = 60
    game.dt = 16
    application.callbacks.init(std, game)
end
