local application = nil
local math = require('math')
local zeebo_fps = require('src/lib/engine/fps')
local zeebo_math = require('src/lib/engine/math')
local decorators = require('src/lib/engine/decorators')
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
    std.color = color
    std.math = zeebo_math
    std.math.random = math.random
    std.game.reset=decorators.reset(application.callbacks, std, game)
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