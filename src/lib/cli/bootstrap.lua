local function bootstrap()
    return [[
local real_io_open = io.open
io.open = function(filename, mode)
    if BOOTSTRAP[filename] and not BOOTSTRAP_DISABLE and mode == 'r' then
        return {
            pointer = 1,
            read = function(self, size)
                if self.pointer >= #BOOTSTRAP[filename] then
                    return nil
                elseif type(size) == 'number' then
                    local content = BOOTSTRAP[filename]:sub(self.pointer, self.pointer + size)
                    self.pointer = self.pointer + #content
                    return content
                elseif size == '*a' then
                    return BOOTSTRAP[filename]
                elseif size == nil then
                    local content = BOOTSTRAP[filename]
                    local line_index = content:find('\n', self.pointer)
                    if line_index then
                        local line = content:sub(self.pointer, line_index - 1)
                        self.pointer = line_index + 1
                        return line
                    else
                        local line = content:sub(self.pointer)
                        self.pointer = #content + 1
                        return line
                    end
                else
                    error("not implemented")
                end
            end,
            close = function() end,
            write = function() end
        }
        
    end
    return real_io_open(filename, mode)
end
]]
end

local function explode_string(input)
    local result = {}
    
    for line in string.gmatch(input, "[^\n]+") do
        table.insert(result, line)
    end
    
    return result
end

local function string_to_hex(input)
    local result = ""
    for i = 1, #input do
        local byte = input:byte(i)
        result = result .. string.format("\\x%02x", byte)
    end
    return result
end

local function map_files(files, prefix_len)
    local list_paths = {}
    local list_files = {}
    local dict_files = {}
    local index = 1

    while index <= #files do
        local file_real_path = files[index]
        local file_real = io.open(file_real_path, 'rb')
        local file_real_content = file_real and file_real:read('*a')
        local file_name = file_real_path:sub(prefix_len)
        
        if file_real_content then
            list_files[#list_files + 1] = file_name
            dict_files[file_name] = string_to_hex(file_real_content)
        else 
            list_paths[#list_paths + 1] = file_name
        end

        index = index + 1
    end

    return list_paths, list_files, dict_files
end

local function merge_dict_and_lists(list_out, dict_out, list_in, dict_in)
    local index = 1
    while index <= #list_in do
        local key = list_in[index]
        list_out[#list_out + 1] = key
        if dict_out and dict_in then
            dict_out[key] = dict_in[key]
        end
        index = index + 1
    end
end

local function build(...)
    local args = {...}

    if BOOTSTRAP then
        BOOTSTRAP_DISABLE = true
    end

    local input_file = io.open(args[1], 'r')
    local output_file = io.open(args[2], 'w')

    if #args <= 2 then
        return false, 'missing src\'s to bundle!'
    end

    if not input_file or not output_file then
        return false, 'usage: lua bootstrap.lua ./dist/main.lua ./dist/cli.lua ./src ./assets'
    end

    local index = 3
    local all_list_paths = {}
    local all_list_files = {}
    local all_dict_files = {}
    while index <= #args do
        local path_src = args[index] or './src'
        local prefix_path = path_src:match("^(.-)/[^/]+$")
        local prefix_len = 0
        
        if not prefix_path then
            return false, 'src path must be a explicit relative path or absolute'
        elseif path_src:sub(1, 2) == './' then
            prefix_len = 3
        else 
            prefix_len = #prefix_path + 2
        end

        do 
            local f = io.open(path_src, 'rb')
            if not f then 
                return false, 'directory not found'
            end
            local can_read = f:read(1)
            if can_read then
                return false, 'path src must be a directory'
            end
            f:close()
        end

        local cmd_pid = io.popen('find '..path_src)
        local cmd_raw, cmd_pid = cmd_pid:read('*a'), cmd_pid:close()
        local list_raw = explode_string(cmd_raw)
        local list_paths, list_files, dict_files = map_files(list_raw, prefix_len)
        merge_dict_and_lists(all_list_files, all_dict_files, list_files, dict_files)
        merge_dict_and_lists(all_list_paths, nil, list_paths, nil)
        index = index + 1
    end

    output_file:write('local BOOTSTRAP = {}\nlocal BOOTSTRAP_DISABLE = false\n')

    do
        local index = 1
        local content = 'local BOOTSTRAP_DIRS = {'
        while index <= #all_list_paths do
            local file_name = all_list_paths[index]
            local file_content = all_dict_files[file_name]
            content = content..'\''..file_name..'\''
            index = index + 1
            if index <= #all_list_paths then
                content = content..', '
            else
                content = content..'}\n'
            end
        end
        output_file:write(content)
    end

    do
        local index = 1
        local content = 'local BOOTSTRAP_LIST = {'
        while index <= #all_list_files do
            local file_name = all_list_files[index]
            local file_content = all_dict_files[file_name]
            content = content..'\''..file_name..'\''
            index = index + 1
            if index <= #all_list_files then
                content = content..', '
            else
                content = content..'}\n'
            end
        end
        output_file:write(content)
    end

    index = 1
    while index <= #all_list_files do
        local file_name = all_list_files[index]
        local file_content = all_dict_files[file_name]
        output_file:write('BOOTSTRAP[\''..file_name..'\'] = \''..file_content..'\'\n')
        index = index + 1
    end

    output_file:write(bootstrap())
    output_file:write(input_file:read('*a'))
    output_file:close()
    input_file:close()

    return true
end

local function dump()
    if not BOOTSTRAP then
        return false, 'cli is not bootstraped'
    end

    do
        local index = 1
        while index <= #BOOTSTRAP_DIRS do
            os.execute('mkdir -p '..BOOTSTRAP_DIRS[index])
            index = index + 1
        end
    end

    do
        local index = 1
        while index <= #BOOTSTRAP_LIST do
            local file = BOOTSTRAP_LIST[index]
            local output_file = io.open(file, 'w')
            output_file:write(io.open(file, 'r'):read('*a'))
            output_file:close()
            index = index + 1
        end
    end

    return true
end

local P = {
    build = build,
    dump = dump
}

return P
