local util_fs = require('src/lib/util/fs')

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

local function build(src, dest)
    local count = 0
    local from = 'main'
    local src_path = util_fs.file(src)
    local dest_path = util_fs.file(dest)
    local relative = src_path and dest_path and src_path.get_unix_path()
    local src_file, src_err = src_path and io.open(src_path.get_fullfilepath())
    local pattern_require1 = '^%s*require%([\'"](.-)[\'"]%)(.*)'
    local pattern_require2 = '^%s*([%w_%-]+)%s*=%s*require%([\'"](.-)[\'"]%)(.*)'
    local pattern_require3 = '^%s*local%s*([%w_%-]+)%s*=%s*require%([\'"](.-)[\'"]%)(.*)'
    local deps_list = {}
    local deps_dict = {}
    local deps_system = {}
    local deps_imported = {}
    local main_content = ''
    local main_before = ''
    local main_after = ''
    local lib_module = nil
    local lib_name = nil
    local lib_var = nil

    if not src_file then
        return false, src_err or 'src is required'
    end

    if not dest_path then
        return false, 'dest is required'
    end

    while src_file do
        if from == 'lib' then
            main_before = main_before..'local '..lib_name..' = nil\n'
            main_after = main_after..lib_name..' = function()\n'
        end
        repeat
            local line = src_file and src_file:read()
            local eof = not line

            line = (line or ''):gsub('\n', '')
            line = line:gsub('^%s*', '')
            line = line:gsub('*%s$', '')
            line = line:gsub('^%-%-$', '')
            line = line:gsub('^_ENV = nil$', '')
            line = line:gsub('%s*%-%-([^\'\"%[%]].*)$', '')

            local line_require1 = { line:match(pattern_require1) }
            local line_require2 = { line:match(pattern_require2) }
            local line_require3 = { line:match(pattern_require3) }
            local line_variable = line_require3[1] or line_require2[1] or '-'
            local line_package = line_require3[2] or line_require2[2] or line_require2[2]
            local line_suffix = line_require3[3] or line_require2[3] or line_require1[2] or ''

            if line_package then
                if not deps_dict[line_package] then
                    deps_list[#deps_list + 1] = line_package
                    deps_dict[line_package]={}
                end
                if #line_require1 > 0 then
                    line = '-'..'- part '
                elseif #line_require2 > 0 then
                    line = '-'..'- global '
                else
                    line = '-'..'- local '
                end
        
                local index = #deps_dict[line_package] + 1
                local libname = line_package:gsub('/', '_'):gsub('%.', '_'):gsub('\\', '_')

                line = line..line_package..' '..libname..' '..line_variable..' '..line_suffix
                deps_dict[line_package][index] = line
            end

            if not eof and line and #line > 0 then
                if from == 'main' then
                    main_content = main_content..line..'\n'
                else
                    main_after = main_after..line..'\n'
                end
            end
        until eof
    
        if from == 'lib' then
            main_after = main_after..'end\n-'..'-\n'
        end

        if src_file then
            src_file:close()
            src_file = nil
        end

        do
            lib_name = nil
            local index = 1
            while index <= #deps_list and not lib_name do
                local lib = deps_list[index]
                if not deps_imported[lib] then
                    local file1 = util_fs.file(lib..'.lua').get_fullfilepath()
                    local file2 = util_fs.file(relative..lib..'.lua').get_fullfilepath()
                    src_file = io.open(file1, 'r') or io.open(file2, 'r')
                    from = src_file and 'lib' or 'system'
                    lib_name = src_file and lib
                    deps_imported[lib] = from
                end
                index = index + 1
            end
        end
    end

    do
        local index1 = 1
        local index2 = 1
        while index1 <= #deps_list do
            index2 = 1
            local lib = deps_list[index1]
            while index2 <= #deps_dict[lib] do
                local line = deps_dict[lib][index2]..'\n'
                local ltype, lfile, lname, lvar, suffix = line:match('^-- (%w+) ([^%s]+) ([^%s]+) ([^%s]+) ([^%s]*)')
                if deps_imported[lib] == 'system' then
                    if not deps_system[lib] then
                        main_before = 'local '..lvar..' = ((function() local x, y = pcall(require, \''..lname
                            ..'\'); return x and y end)()) or _G.'..lvar..'\n'..main_before
                        deps_system[lib] = true
                    end
                    main_after = main_after:gsub(line, '')
                    main_content = main_content:gsub(line, '')                    
                elseif ltype == 'part' then
                    local replacer = lname..'()\n'
                    main_after = main_after:gsub(line, replacer)
                    main_content = main_content:gsub(line, replacer)
                else
                    local replacer = lvar..' = '..lname..'()\n'
                    if ltype == 'local' then
                        replacer = 'local '..replacer
                    end
                    main_after = main_after:gsub(line, replacer)
                    main_content = main_content:gsub(line, replacer)
                end
                index2 = index2 + 1
            end
            index1 = index1 + 1
        end
    end

    do
        main_content = 'local function main()\n'..main_content..'end\n'
        main_content = main_before..main_content..main_after
        main_content = main_content..'return main()\n'
    end

    src_file, src_err = io.open(dest_path.get_fullfilepath(), 'w')
    
    if not src_file then
        return false, src_err or 'cannot write bundle file'
    end

    src_file:write(main_content)
    src_file:close()

    return true
end

--! @}
--! @}

local P = {
    build=build
}

return P
