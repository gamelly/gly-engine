
local os = require('os')

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
        end

        index = index + 1
    end

    return list_files, dict_files
end

local function main(args)
    local input_file = io.open(args[1], 'r')
    local output_file = io.open(args[2], 'w')
    local path_src = args[3] or './src'
    local prefix_path = path_src:match("^(.-)/[^/]+$")
    local prefix_len = 0
    
    if not prefix_path then
        print('path_src must be a explicit relative path or absolute')
        return 1
    elseif path_src:sub(1, 2) == './' then
        prefix_len = 3
    else 
        prefix_len = #prefix_path + 2
    end

    if not input_file or not output_file then
        print('usage: lua bootstrap.lua ./dist/main.lua ./dist/cli.lua ./src')
        return 1
    end

    do 
        local f = io.open(path_src, 'rb')
        if not f then 
            print('directory not found')
            return 1
        end
        local can_read = f:read(1)
        if can_read then
            print('path_src must be a directory')
            return 1
        end
        f:close()
    end

    local index = 1
    local cmd_pid = io.popen('find '..path_src)
    local cmd_raw, cmd_pid = cmd_pid:read('*a'), cmd_pid:close()
    local list_raw = explode_string(cmd_raw)
    local list_files, dict_files = map_files(list_raw, prefix_len)


    output_file:write([[
local real_io_open = io.open
io.open = function(filename, mode)
    if _G[filename] then
        return {
            pointer = 1,
            read = function(self, size)
                if self.pointer >= #_G[filename] then
                    return nil
                elseif type(size) == 'number' then
                    local content = _G[filename]:sub(self.pointer, size)
                    self.pointer = self.pointer + #content
                    return content
                elseif size == '*a' then
                    return _G[filename]
                elseif size == nil then
                    local content = _G[filename]
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
]])

    while index <= #list_files do
        local file_name = list_files[index]
        local file_content = dict_files[file_name]
        output_file:write('_G[\''..file_name..'\'] = \''..file_content..'\'\n')
        index = index + 1
    end

    output_file:write(input_file:read('*a'))
    output_file:close()
    input_file:close()

    return 0
end

os.exit(main(arg))
