local zeebo_module = require('src/lib/engine/module')
local engine_game = require('src/lib/engine/game')
local engine_math = require('src/lib/engine/math')
local engine_color = require('src/lib/object/color')
local engine_math = require('src/lib/engine/math')
local engine_http = require('src/lib/engine/http')
local engine_csv = require('src/lib/engine/csv')
local engine_draw_fps = require('src/lib/engine/draw_fps')
local engine_draw_poly = require('src/lib/engine/draw_poly')
local application_default = require('src/lib/object/application')
local color = require('src/lib/object/color')
local game = require('src/lib/object/game')
local std = require('src/lib/object/std')
local application = nil

function native_callback_loop(milis)
    game.milis = milis
    application.callbacks.loop(std, game)
    return game.dt
end

function native_callback_draw()
    native_draw_start()
    application.callbacks.draw(std, game)
    native_draw_flush()
end

function native_callback_resize(width, height)
    game.width = width
    game.height = height
end

function native_callback_keyboard(key, value)
    std.key.press[key] = value
end

function native_callback_init(width, height, game_lua)
    application = zeebo_module.loadgame(game_lua)
    
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
        :package('csv', engine_csv)
        :run()

    std.draw.clear=native_draw_clear
    std.draw.color=native_draw_color
    std.draw.font=native_draw_font
    std.draw.text=native_draw_text
    std.draw.rect=native_draw_rect
    std.draw.line=native_draw_line

    game.width = width
    game.height = height
    game.fps = 60
    game.dt = 16
    application.callbacks.init(std, game)
end
