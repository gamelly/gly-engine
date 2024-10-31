function support()
    local file = io.open('README.md')
    local content = file:read('*a')
    local begin_pos = content:find('#### CLI Platform Support')
    local end_pos = content:find('\n%-%-%-\n')
    content = content:sub(begin_pos, end_pos)
    content = content:gsub(':ok:', 'yes')
    content = content:gsub(':x:', 'no')
    file:close()
    return content
end

function commands()
    local name = 'src/cli/main.lua'
    local file = io.open(name)
    local src = file:read('*a')
    local content = ''
    local next_cmd = src:gmatch('%.add_subcommand%(\'([%w%-]+)\'')
    repeat
        local cmd = next_cmd()
        if cmd then
            local pid = io.popen('lua '..name..' help '..cmd)
            local usage = pid:read('*a')
            local tutorial = usage:gsub('usage: ', ''):gsub(name, 'gly-cli')
            content = content..'@code{.sql}\n'..tutorial..'\n@endcode\n'
            pid:close()
        end
    until not cmd
    file:close()
    return content
end

local function source(file_name)
    local content = ''
    local file = io.open(file_name, 'r')
    repeat
        local line = file:read('*l')
        if line and not line:find('^%-%-%!') then
            content = content..line..'\n'
        end
    until not line
    file:close()
    return content
end

local function group(a, b, c)
    return '//! @defgroup '..a..'\n//! @{\n//! @defgroup '..b..' '..c..'\n//! @{\n'
end

local function game_screenshot(game)
    return '//! @par Screenshot \n//! @li not avaliable\n'
end

local function game_requires(game)
    local content = ''
    local libraries = game.config and game.config.require or ''
    local next_library = libraries:gmatch('%S+')
    repeat
        local library = next_library()
        if library then
            content = content..' @c '..library
        end
    until not library
    if #content > 0 then
        content = '//! @pre require '..content..'\n'
    end
    return content
end

function main()
    local file = io.open(arg[1], 'r')
    if not file then
        return
    end

    local is_txt = arg[1]:sub(#arg[1] - 3) == '.txt'
    local is_lua = arg[1]:sub(#arg[1] - 3) == '.lua'
    local is_game = arg[1]:sub(#arg[1] - 7) == 'game.lua' and arg[1]:find('examples')
    local renamefunc_pattern = '@renamefunc ([%w_]+)'
    local hideparam_pattern = '@hideparam ([%w_]+)'
    local include_pattern = '^local [%w_%-]+ = require%(\'(.-)\'%)'
    local function_pattern = '^local function ([%w_]+%b())'
    local literal_pattern = '^local ([%w_%-]+) = ([%d%w\'"-_]+)'
    local command_pattern = '@call (%w+)'
    local doxygen_pattern = '%-%-%!'

    if is_txt then
        io.write('/**\n')
    end

    if is_lua then
        io.write('//! @file '..arg[1]..'\n')
    end

    if is_game then
        local game = dofile(arg[1])
        local game_name = arg[1]:match('([%w_]+)/game.lua$')
        io.write(group('Examples', game_name, game.meta.title))
        io.write(game_requires(game))
        io.write('//! @short @c \\@'..game_name..'\n')
        io.write('//! @author '..game.meta.author..'\n')
        io.write('//! @version '..game.meta.version..'\n')
        io.write('//! @par Brief \n//! @details '..game.meta.description..'\n')
        io.write(game_screenshot(game))
        game_src = source(arg[1])
    end

    local rename_function = false
    local params_hiden = {}

    repeat
        local line = file:read('*l')

        if line then
            local breakline = true
            local command = line:match(command_pattern)
            local doxygen = line:match(doxygen_pattern)
            local include = line:match(include_pattern)
            local clojure = line:match(function_pattern)
            local hideparam = line:match(hideparam_pattern)
            local rename_func = line:match(renamefunc_pattern)
            local variable, literal = line:match(literal_pattern)

            if is_lua and doxygen then
                line = line:gsub(doxygen_pattern, '//!')
            end

            if rename_function and clojure then
                clojure = clojure:gsub('^([%w_]+)', rename_function)
                rename_function = false
            end

            if #params_hiden > 0 and clojure then
                local index = 1
                while index <= #params_hiden do
                    clojure = clojure:gsub(params_hiden[index]..'[,]?', '')
                    index = index + 1
                end
                params_hiden = {}
            end

            if rename_func then
                rename_function = rename_func
            elseif hideparam then
                params_hiden[#params_hiden + 1] = hideparam
            elseif include then
                io.write('#include "'..include..'.lua"')
            elseif is_game and not doxygen then
                breakline = false
            elseif clojure then
                io.write('local function-'..clojure..';')
            elseif variable and literal then
                io.write('local '..variable..' = '..literal..';')
            elseif command and _G[command] then
                io.write(_G[command](line))
            elseif doxygen then
                io.write(line)
            elseif is_txt then
                io.write(line)
            elseif line:find('%S') then
                breakline = false
            end
            
            if breakline then
                io.write('\n')
            end
        end
    until not line

    if is_txt then
        io.write(' */\n')
    end

    if is_game then
        io.write('//! @par Source Code \n//! @code{.java}\n'..source(arg[1])..'\n//! @endcode\n')
        io.write('//! @} @}\n')
    end
end

main()
