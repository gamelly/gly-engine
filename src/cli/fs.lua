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
            local line = src_file:read('l')
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

local P = {
    move = move,
    moveLua = moveLua,
    build = build
}

return P
