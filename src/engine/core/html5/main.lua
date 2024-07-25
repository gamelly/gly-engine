local application = nil
local zeebo_module = require('src/lib/engine/module')
local engine_math = require('src/lib/engine/math')
local engine_color = require('src/lib/object/color')
local engine_math = require('src/lib/engine/math')
local engine_http = require('src/lib/engine/http')
local engine_csv = require('src/lib/engine/csv')
local application_default = require('src/lib/object/application')
local color = require('src/lib/object/color')
local game = require('src/lib/object/game')
local std = require('src/lib/object/std')

local function browser_update(milis)
    game.milis = milis
    if application.callbacks.loop then
        application.callbacks.loop(std, game)
    end
    return game.dt
end

local function browser_draw()
    application.callbacks.draw(std, game)
end

local function browser_keyboard(key, value)
    std.key.press[key] = value
end

local function browser_init(width, height)
    application = (load(game_lua))()
    zeebo_module.require(std, game, application)
        :package('@math', engine_math)
        :package('@color', engine_color)
        :package('math', engine_math.clib)
        :package('random', engine_math.clib_random)
        :package('http', engine_http, browser_protocol_http)
        :package('csv', engine_csv)
        :run()

    std.draw = browser_canvas
    game.width = width
    game.height = height
    game.fps = 60
    game.dt = 16
    application.callbacks.init(std, game)
end

local P = {
    init=browser_init,
    update=browser_update,
    keyboard=browser_keyboard,
    draw=browser_draw
}

return P
