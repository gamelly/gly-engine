--! @short unify files
--! @brief groups code into a single source
--! @param[in] src_path folder with lua includes
--! @param[in] src_file entry file
--! @param[in] dest_file packaged file output
--! @par Input
--! @li @c lib_common_math.lua
--! @code
--! local function sum(a, b)
--!     return a + b
--! end
--! 
--! local P = {
--!     sum = sum
--! }
--! 
--! return P
--! @endcode
--!
--! @li @c main.lua
--! @code
--! local os = require('os')
--! local zeebo_math = require('lib_common_math')
--! 
--! print(zeebo_math.sum(1, 2))
--! os.exit(0)
--! @endcode
--! 
--! @par Output 
--! @li @c main.lua
--! @code
--! local os = require('os')
--! local lib_common_math = nil
--! 
--! local function main()
--!     local zeebo_math = lib_common_math()
--!     print(zeebo_math.sum(1, 2))
--!     os.exit(0)
--! end
--! 
--! lib_common_math = function()
--!     local function sum(a, b)
--!         return a + b
--!     end
--! 
--!     local P = {
--!         sum = sum
--!     }
--!     
--!     return P
--! end
--! 
--! main()
--! @endcode
local function build(src_path, src_filename, dest)
    local pattern_require = "local ([%w_%-]+) = require%('(.-)'%)"
    local pattern_gameload = "([%w_%-%.]+) = std%.node%.load%('(.-)'%)"
    local from = 'main'
    local src_in = src_path..src_filename
    local src_file = io.open(src_in, 'r')
    local dest_file = io.open(dest, 'w')
    local relative_path = src_path:gsub('[%w_-]+', '..')
    local deps_imported = {}
    local deps_var_name = {}
    local deps_module_path = {}
    local main_content = ''
    local main_before = ''
    local main_after = ''
    local lib_module = nil
    local lib_name = nil
    local lib_var = nil
    local index = nil

    repeat
        if from == 'system' then
            local os = function() local x, y = pcall(require, 'os'); return x and y end or _G.os

            main_before = 'local '..lib_var..' = ((function() local x, y = pcall(require, \''..lib_module
                ..'\'); return x and y end)()) or _G.'..lib_var..'\n'..main_before
        end
        if src_file then
            if from == 'lib' then
                main_before = main_before..'local '..lib_name..' = nil\n'
                main_after = main_after..lib_name..' = function()\n'
            end
            repeat
                local line = src_file:read()
                if line then
                    line = line:gsub('\n', '')
                    line = line:gsub('^%s*', '')
                    line = line:gsub('*%s$', '')
                    line = line:gsub('^%-%-$', '')
                    line = line:gsub('^_ENV = nil$', '')
                    line = line:gsub('%s*%-%-([^\'\"%[%]].*)$', '')
                end

                local line_require = line and { line:match(pattern_require) }
                local line_gameload = line and { line:match(pattern_gameload) }

                if line_gameload and #line_gameload > 0 then
                    local index = #deps_var_name + 1
                    local gamefile = line_gameload[2]:gsub('/', '_'):gsub('%.lua$', '')
                    deps_var_name[index] = line_gameload[1]
                    deps_module_path[index] = line_gameload[2]:gsub('%.lua$', '')
                    main_content = main_content..'local '..line_gameload[1]..' = std.node.load('..gamefile..')\n'
                elseif line_require and #line_require > 0 then
                    local index = #deps_var_name + 1
                    deps_var_name[index] = line_require[1]
                    deps_module_path[index] = line_require[2]
                    if from == 'main' then
                        main_content = main_content..'-'..'-'..line_require[2]..line_require[1]..'-'..'-\n'
                    else
                        main_after = main_after..'-'..'-'..line_require[2]..line_require[1]..'-'..'-\n'
                    end
                elseif line and #line > 0 and from == 'main' then
                    main_content = main_content..line..'\n'
                elseif line and #line > 0 and from == 'lib' then
                    main_after = main_after..line..'\n'
                end
            until not line
            if from == 'lib' then
                main_after = main_after..'end\n'
            end
        end

        if src_file then
            src_file:close()
            src_file = nil
        end

        index = 1
        src_in = nil
        while not src_in and index <= #deps_var_name do
            lib_module = deps_module_path[index]
            lib_var = deps_var_name[index]
            local lib =  lib_module and lib_var and lib_module..lib_var
            if lib and not deps_imported[lib] then
                lib_name = lib_module:gsub('/', '_')
                src_in = src_path..lib_module..'.lua'
                src_file = io.open(src_in, 'r') or io.open(lib_module..'.lua', 'r')
                src_file = src_file or io.open(src_path..relative_path..lib_module..'.lua')
                from = src_file and 'lib' or 'system'
                deps_imported[lib] = from
            end
            index = index + 1
        end
    until not src_in

    index = 1
    while index <= #deps_var_name do
        lib_module = deps_module_path[index]
        lib_name = lib_module:gsub('/', '_')
        lib_var = deps_var_name[index]
        local lib = lib_module and lib_var and lib_module..lib_var
        if lib and deps_imported[lib] then
            local search = '%-%-'..lib_module..lib_var..'%-%-\n'
            local replace = 'local '..lib_var..' = '..lib_name..'()\n'
            local replacer = deps_imported[lib] == 'system' and '' or replace
            main_after = main_after:gsub(search, replacer)
            main_content = main_content:gsub(search, replacer)
        end
        index = index + 1
    end

    do
        main_content = 'local function main()\n'..main_content..'end\n'
        main_content = main_before..main_content..main_after
        main_content = main_content..'return main()\n'
    end

    dest_file:write(main_content)
    dest_file:close()
    return true
end

local P = {
    build=build
}

return P
