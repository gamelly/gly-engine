local application = nil
local engine_math = require('src/lib/engine/math')
local engine_color = require('src/lib/object/color')
local engine_math = require('src/lib/engine/math')
local application_default = require('src/lib/object/application')
local color = require('src/lib/object/color')
local game = require('src/lib/object/game')
local std = require('src/lib/object/std')

local function browser_update(milis)
    game.milis = milis
    application.callbacks.loop(std, game)
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
    engine_math.install(std, game, application)
    engine_color.install(std, game, application)
    engine_math.clib.install(std, game, application)
    engine_math.clib_random.install(std, game, application)
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
