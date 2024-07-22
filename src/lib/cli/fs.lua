local function ls(src_path)
    local ls_cmd = io.popen('ls -1 '..src_path)
    local ls_files = {}

    if ls_cmd then
        repeat
            local line = ls_cmd:read()
            ls_files[#ls_files + 1] = line
        until not line
        ls_cmd:close()
    end

    return ls_files
end

local function clear(src_path)
    if os.execute('rm --version > /dev/null 2> /dev//null') then
        os.execute('mkdir -p '..src_path)
        os.execute('rm -Rf '..src_path..'/*')
    else
        src_path = src_path:gsub('/', '\\')
        os.execute('mkdir '..src_path)
        os.execute('rmdir /s /q '..src_path..'\\*')
    end
end

local function move(src_in, dist_out)
    local src_file = io.open(src_in, "rb")
    local dist_file = io.open(dist_out, "wb")

    if src_file and dist_file then
        repeat
            local buffer = src_file:read(1024)
            if buffer then
                dist_file:write(buffer)
            end
        until not buffer
    end

    if src_file then
        src_file:close()
    end
    if dist_file then
        dist_file:close()
    end
end

local function moveLua(src_in, dist_path, dist_file)
    local deps = {}
    local pattern = "local ([%w_%-]+) = require%('src/(.-)'%)"
    local src_file = io.open(src_in, "r")
    local dist_file_normalized = src_in:gsub('/', '_'):gsub('^src_', '')
    local dist_out = dist_path:gsub('/$', '')..'/'..(dist_file or dist_file_normalized)
    local dist_file = io.open(dist_out, "w")

    if src_file and dist_file then
        repeat
            local line = src_file:read()
            if line then
                local line_require = { line:match(pattern) }
                if line_require and #line_require > 0 then
                    local var_name = line_require[1]
                    local module_path = line_require[2]
                    deps[#deps + 1] = 'src/'..module_path..'.lua'
                    dist_file:write('local '..var_name..' = require(\''..module_path:gsub('/', '_')..'\')\n')
                else
                    dist_file:write(line, '\n')
                end
            end
        until not line
    end

    if src_file then
        src_file:close()
    end
    if dist_file then
        dist_file:close()
    end

    return deps
end

local function build(src_in, dist_path)
    local main = true
    local deps = {}
    local deps_builded = {}

    repeat
        if src_in:sub(-4) == '.lua' then
            local index = 1
            local index_deps = #deps
            local file_name = main and 'main.lua'
            local new_deps = moveLua(src_in, dist_path, file_name)
            while index <= #new_deps do
                deps[index_deps + index] = new_deps[index]
                index = index + 1
            end
        end

        main = false
        src_in = nil
        local index = 1
        while index <= #deps and not src_in do
            local dep = deps[index]
            if not deps_builded[dep] then
                deps_builded[dep] = true
                src_in = dep
            end
            index = index + 1
        end
    until not src_in
end

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
local function bundler(src_path, src_file, dest_file)
    local pattern = "local ([%w_%-]+) = require%('(.-)'%)"
    local dest_file = io.open(dest_file, 'w')
    local main_file = io.open(src_path..src_file, 'r')
    local main_content = ''
    local main_before = ''
    local main_after = ''

    repeat
        local line = main_file:read()
        if line then
            local line_require = { line:match(pattern) }

            if line_require and #line_require > 0 then
                local var_name = line_require[1]
                local module_path = line_require[2]
                local module_file = io.open(src_path..module_path..'.lua', 'r')
                if not module_file then
                    main_before = main_before..line..'\n'
                else
                    local lib_name = module_path:gsub('/', '_')
                    local lib_content = module_file:read('*all')
                    main_before = main_before..'local '..lib_name..' = nil\n'
                    main_content = main_content..'local '..var_name..' = '..module_path..'()\n'
                    main_after = main_after..lib_name..' = function()\n'..lib_content..'\nend\n'
                    module_file:close()
                end
            else
                main_content = main_content..line..'\n'
            end
        end
    until not line

    do
        main_content = 'local function main()\n'..main_content..'\nend'
        main_content = main_before..'\n'..main_content..'\n'..main_after
        main_content = main_content..'\nreturn main()\n'
    end

    dest_file:write(main_content)
    dest_file:close()
    main_file:close()
end

local P = {
    ls = ls,
    move = move,
    moveLua = moveLua,
    bundler = bundler,
    build = build,
    clear = clear
}

return P
