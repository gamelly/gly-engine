local application = nil
local math = require('math')
local zeebo_fps = require('src/lib/common/fps')
local zeebo_math = require('src/lib/common/math')
local decorators = require('src/lib/common/decorators')
local application_default = require('src/object/application')
local game = require('src/object/game')
local std = require('src/object/std')

local function browser_update()
    application.callbacks.loop(std, game)
    return game.dt
end

local function browser_draw()
    application.callbacks.draw(std, game)
end

local function browser_init(width, height)
    application = (load(game_lua))()
    std.math = zeebo_math
    std.math.random = math.random
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
    draw=browser_draw
}

return P
