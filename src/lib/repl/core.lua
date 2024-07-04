--! @startebnf
--! line= [frame_skip], variable, ["=", value (* assignment *)];
--! frame_skip = [digit], "!" ;
--! digit = { ? 0 - 9 ? }- ;
--! @endebnf
package.path=package.path..';dist/?.lua' -- TODO make more smarth solution
local game_obj = require('src_object_game')
local key_obj = require('src_object_keys')
local mathstd = require('math')
local math = require('lib_math')

local function mock() return end

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

local function evaluate(var, assign, std_lib, game_obj)
    local script = ''

    if assign and #assign > 0 then
        script = 'return function(std, game)\n'..var..'=('..assign..')\n return ('..var..')\nend'
    elseif var and #var > 0 then
        script = 'return function(std, game)\nreturn ('..var..')\nend'
    end

    if script and #script > 0 then
        local ok, output = pcall(function()
            local func, err = load(script)
            if func then
                local result = func()
                return result(std_lib, game_obj)
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
    local file_name = arg[1] or 'dist/game.lua'
    local file_src = io.open(file_name, "r")
    local game = file_src and load(file_src:read('*all'))
    local stdlib = {draw = {}}
    local started = false

    if not file_src or not game then
        error('game not found!')
    end

    -- init the game
    game = game()
    stdlib.math = math
    stdlib.math.random = mathstd.random
    stdlib.draw.clear=mock
    stdlib.draw.color=mock
    stdlib.draw.rect=mock
    stdlib.draw.text=mock
    stdlib.draw.font=mock
    stdlib.draw.line=mock
    stdlib.draw.poly=mock
    stdlib.key = key_obj
    game.callbacks.init(stdlib, game_obj)

    while true do
        local index = 1
        line = io.read()

        if line == nil or line == '?' then
            break
        end

        frames, line = line_skip_frames(line)
        variable, assignment = line_assignment(line)
        frames = tonumber(frames)

        local ok, output = evaluate(variable, assignment, stdlib, game_obj)
        if ok then
            print(output)
        else
            io.stderr:write(output)
            print('\n')
        end

        if not started and frames > 0 and game.callbacks.init then
            game.callbacks.init(stdlib, game_obj)
            started = true
        end

        while index <= frames do
            if game.callbacks.loop then
                game.callbacks.loop(stdlib, game_obj)
            end
            if game.callbacks.draw then
                game.callbacks.draw(stdlib, game_obj)
            end
            index = index + 1
        end
    end
end

main()
