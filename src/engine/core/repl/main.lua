--! @file src/lib/repl/main.lua
--! @short Read Eval Print Loop
--! @brief an interpreter to debuging the game via stdio.
--! @par Extended Backus-Naur Form
--! @startebnf
--! line = exit | frame_skip | [frame_skip], variable, ["=", value (* assignment *)];
--! frame_skip = [digit], "!" ;
--! digit = { ? 0 - 9 ? }- ;
--! exit = "?" ;
--! @endebnf
local zeebo_module = require('src/lib/engine/module')
local engine_game = require('src/lib/engine/game')
local engine_math = require('src/lib/engine/math')
local engine_color = require('src/lib/object/color')
local engine_http = require('src/lib/engine/http')
local engine_encoder = require('src/lib/engine/encoder')
local engine_draw_fps = require('src/lib/draw/fps')
local engine_draw_poly = require('src/lib/draw/poly')
local protocol_curl = require('src/lib/protocol/http_curl')
local library_csv = require('src/third_party/csv/rodrigodornelles')
local library_json = require('src/third_party/json/rxi')
local application_default = require('src/lib/object/application')
local game = require('src/lib/object/game')
local std = require('src/lib/object/std')

local function line_skip_frames(line_src)
    local frames, line = line_src:match('(%d+)!(.*)')
    if frames and line then
        return frames, line
    end
    frames, line = line_src:match('(!)(.*)')
    if frames and line then
        return 1, line
    end
    return 0, line_src
end

local function line_assignment(line)
    local variable, assignment = line:match('(.*)=(.*)')
    if variable and assignment then
        return variable, assignment
    end
    return line, ''
end

local function evaluate(var, assign, std, game, application)
    local script = ''

    if assign and #assign > 0 then
        script = 'return function(std, game, application)\n'..var..'=('..assign..')\n return ('..var..')\nend'
    elseif var and #var > 0 then
        script = 'return function(std, game, application)\nreturn ('..var..')\nend'
    end

    if script and #script > 0 then
        local ok, output = pcall(function()
            local func, err = load(script)
            if func then
                local result = func()
                return result(std, game, application)
            else
                error(err)
            end
        end)

        return ok, tostring(output)
    end

    return true, ''
end

local function main()
    local frames = 0
    local variable = ''
    local assignment = ''
    local started = false
    local application = zeebo_module.loadgame(arg[1]) or application_default

    -- init the game
    zeebo_module.require(std, game, application)
        :package('@game', engine_game)
        :package('@math', engine_math)
        :package('@color', engine_color)
        :package('load', zeebo_module.load)
        :package('math', engine_math.clib)
        :package('random', engine_math.clib_random)
        :package('http', engine_http, protocol_curl)
        :package('csv', engine_encoder, library_csv)
        :package('json', engine_encoder, library_json)
        :run()
    
    while true do
        local index = 1
        local ok, line = pcall(io.read)

        if not ok or line == nil or line == '?' then
            break
        end

        frames, line = line_skip_frames(line)
        variable, assignment = line_assignment(line)
        frames = tonumber(frames)

        local ok, output = evaluate(variable, assignment, std, game, application)
        if ok then
            print(output)
        else
            io.stderr:write(output)
            print('\n')
        end

        if not started and frames > 0 and application.callbacks.init then
            application.callbacks.init(std, game)
            started = true
        end

        while index <= frames do
            if application.callbacks.loop then
                application.callbacks.loop(std, game)
            end
            if application.callbacks.draw then
                application.callbacks.draw(std, game)
            end
            index = index + 1
        end
    end
end

if not package.loaded['modulename'] then
    main()
end
