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
local math = require('math')
local std = require('src/object/std')
local game = require('src/object/game')
local application_default = require('src/object/application')
local zeebo_math = require('src/lib/common/math')

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
    local line = nil
    local frames = 0
    local variable = ''
    local assignment = ''
    local file_name = arg[1]
    local started = false
    local application = application_default

    if file_name then
        local file_src = io.open(file_name, "r")
        local apploader = file_src and load(file_src:read('*all'))
        if not file_src then
            error('game not found!'..file_name)
        end
        if not apploader then
            error('game error!')
        end
        application = apploader()
    end

    -- init the game
    std.math = zeebo_math
    std.math.random = math.random
    application.callbacks.init(std, game)

    while true do
        local index = 1
        line = io.read()

        if line == nil or line == '?' then
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
