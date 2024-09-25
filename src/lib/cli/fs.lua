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
    if os.execute('rm -'..'-version > /dev/null 2> /dev//null') then
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

local P = {
    ls = ls,
    move = move,
    clear = clear
}

return P
