--! @defgroup cli
--! @{
--! @defgroup bundler
--! @{
--!
--! @short unify lua files
--!
--! @details
--! The bundler is for general use and can be used in any lua code in addition to games made for the gly engine.
--!
--! @li optimized recursive search for dependencies in your files.
--! @li minification by removing comments, extrabreaklines and tabulations.
--! @li compatibility with lua distributions that do not expose standard libs in require.
--!
--! @par Instalation
--!
--! @todo coming soon, just bundler as a utility `.lua` script to use in your CI system. @n (without the engine)
--!
--! @par Usage
--! @code{.sql}
--! lua cli.lua bundler src/main.lua --dist ./dist
--! @endcode
--!
--! @par Result
--! @li @b Input
--! - @c lib_common_math.lua
--! @code{.java}
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
--! - @c main.lua
--! @code{.java}
--! local os = require('os')
--! local zeebo_math = require('lib_common_math')
--! 
--! print(zeebo_math.sum(1, 2))
--! os.exit(0)
--! @endcode
--! 
--! @li @b Output 
--! - @c main.lua
--! @code{.java}
--! local os = ((function() local x, y = pcall(require, 'os'); return x and y end)()) or _G.os
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
--! @}
--! @}

local function build(src_path, src_filename, dest)
    local pattern_require = "local ([%w_%-]+) = require%('(.-)'%)"
    local from = 'main'
    local src_in = src_path..src_filename
    local src_file = io.open(src_in, 'r')
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

    repeat
        if from == 'system' then
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

                if line_require and #line_require > 0 then
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
                main_after = main_after..'end\n-'..'-\n'
            end
        end

        if src_file then
            src_file:close()
            src_file = nil
        end

        local index = 1
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

    local index = 1
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

    local dest_file, dest_err = io.open(dest, 'w')
    if not dest_file then
        return false, dest_err
    end

    dest_file:write(main_content)
    dest_file:close()
    
    return true
end

local P = {
    build=build
}

return P
