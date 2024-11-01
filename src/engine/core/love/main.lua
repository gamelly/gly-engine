local os = require('os')
--
local zeebo_module = require('src/lib/engine/raw/module')
--
local core_draw = require('src/engine/core/love/draw')
local core_loop = require('src/engine/core/love/loop')
local lib_api_encoder = require('src/lib/engine/api/encoder')
local lib_api_game = require('src/lib/engine/api/game')
local lib_api_hash = require('src/lib/engine/api/hash')
local lib_api_http = require('src/lib/engine/api/http')
local lib_api_i18n = require('src/lib/engine/api/i18n')
local lib_api_key = require('src/lib/engine/api/key')
local lib_api_math = require('src/lib/engine/api/math')
local lib_draw_fps = require('src/lib/engine/draw/fps')
local lib_draw_poly = require('src/lib/engine/draw/poly')
local lib_draw_ui = require('src/lib/engine/draw/ui')
local lib_raw_bus = require('src/lib/engine/raw/bus')
local lib_raw_memory = require('src/lib/engine/raw/memory')
local lib_raw_node = require('src/lib/engine/raw/node')
--
local cfg_json_rxi = require('src/third_party/json/rxi')
local cfg_http_curl_love = require('src/lib/protocol/http_curl_love')
--
local util_arg = require('src/lib/common/args')
local util_lua = require('src/lib/util/lua')
--
local color = require('src/lib/object/color')
local std = require('src/lib/object/std')

local cfg_poly = {
    triangle=core_draw.triangle,
    poly=love.graphics.polygon,
    modes={'fill', 'line', 'line'}
}

local cfg_keys = {
    ['escape']='menu',
    ['return']='a',
    up='up',
    left='left',
    right='right',
    down='down',
    z='a',
    x='b',
    c='c',
    v='d'
}

local cfg_game_api = {
    set_fullscreen = love.window.setFullscreen,
    get_fullscreen = love.window.getFullscreen,
    set_title = love.window.setTitle,
    get_fps = love.timer.getFPS,
    quit = love.event.quit
}

function love.load(args)
    local screen = util_arg.get(args, 'screen')
    local fullscreen = util_arg.has(args, 'fullscreen')
    local game_title = util_arg.param(arg, {'screen'}, 2)
    local application = zeebo_module.loadgame(game_title)
    local engine = {offset_x=0,offset_y=0}
    
    if screen then
        local w, h = screen:match('(%d+)x(%d+)')
        application.data.width = tonumber(w)
        application.data.height = tonumber(h)
    end

    if application then
        std.game.width = application.data.width
        std.game.height = application.data.height
        love.window.setMode(std.game.width, std.game.height, {
            fullscreen=fullscreen,
            resizable=true
        })
    end

    zeebo_module.require(std, application, engine)
        :package('@bus', lib_raw_bus)
        :package('@node', lib_raw_node)
        :package('@memory', lib_raw_memory)
        :package('@game', lib_api_game, cfg_game_api)
        :package('@math', lib_api_math)
        :package('@key', lib_api_key, cfg_keys)
        :package('@draw.poly', lib_draw_poly, cfg_poly)
        :package('@draw.fps', lib_draw_fps)
        :package('@draw.ui', lib_draw_ui)
        :package('@draw', core_draw)
        :package('@loop', core_loop)
        :package('@color', color)
        :package('math', lib_api_math.clib)
        :package('math.random', lib_api_math.clib_random)
        :package('http', lib_api_http, cfg_http_curl_love)
        :package('json', lib_api_encoder, cfg_json_rxi)
        :package('i18n', lib_api_i18n, util_lua.get_sys_lang)
        :package('hash', lib_api_hash, {'love'})
        :run()

    std.node.spawn(application)

    engine.root = application
    engine.current = application

    std.game.title(application.meta.title..' - '..application.meta.version)

    love.update = std.bus.trigger('loop')
    love.resize = std.bus.trigger('resize')
    love.draw = std.bus.trigger('draw')
    love.keypressed = std.bus.trigger('rkey1')
    love.keyreleased = std.bus.trigger('rkey0')
    
    std.bus.emit_next('load')
    std.bus.emit_next('init')
end
