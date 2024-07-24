local os = require('os')
local decorators = require('src/lib/engine/decorators')
local zeebo_module = require('src/lib/engine/module')
local zeebo_args = require('src/lib/common/args')
local engine_math = require('src/lib/engine/math')
local engine_draw = require('src/engine/core/love/draw')
local engine_keys = require('src/engine/core/love/keys')
local engine_loop = require('src/engine/core/love/loop')
local engine_color = require('src/lib/object/color')
local engine_http = require('src/lib/engine/http')
local protocol_curl = require('src/lib/protocol/http_curl')
local game = require('src/lib/object/game')
local std = require('src/lib/object/std')

function love.load(args)
    local w, h = love.graphics.getDimensions()
    local screen = args and zeebo_args.get(args, 'screen')
    local game_title = zeebo_args.param(arg, {'screen'}, 2)
    local application = zeebo_module.loadgame(game_title)

    if screen then
        w, h = screen:match('(%d+)x(%d+)')
        w, h = tonumber(w), tonumber(h)
        love.window.setMode(w, h, {resizable=true})
    end
    if not application then
        error('game not found!')
    end
    
    zeebo_module.require(std, game, application)
        :package('@math', engine_math)
        :package('@draw', engine_draw)
        :package('@keys', engine_keys)
        :package('@loop', engine_loop)
        :package('@color', engine_color)
        :package('math', engine_math.clib)
        :package('random', engine_math.clib_random)
        :package('http', engine_http, protocol_curl)
        :run()

    std.draw.poly=decorators.poly(0, love.graphics.polygon)
    game.width, game.height = w, h
    love.window.setTitle(application.meta.title..' - '..application.meta.version)
    application.callbacks.init(std, game)
end
