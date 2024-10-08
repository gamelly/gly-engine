local function replace(args)
    local file_in = io.open(args.file,'r')

    if not file_in then
        return false, 'file not found: '..args.file
    end
    
    local content = (file_in:read('*a') or ''):gsub(args.format, args.replace)
    file_in:close()

    local file_out = io.open(args.dist, 'w')

    file_out:write(content)
    file_out:close()

    return true
end

local function download(args)
    return false, 'not implemented!'
end

local function vim_xxd_i(args)
    local file_in = io.open(args.file, 'rb')
    local file_out = args.dist and io.open(args.dist, 'w')

    if not file_in then
        return false, 'file not found: '..args.file
    end

    if not file_out then
        if args.dist then
            return false, 'failed to write:'..args.dist
        else
            file_out = io.stdout
        end
    end

    local content, length, column = '', 0, 0
    local const =  args.const and 'const ' or '' 
    local var_name = args.name or args.file:gsub('[%._/]', '_'):gsub("__+", "_"):gsub('^_', '')

    file_out:write(const..'unsigned char '..var_name..'[] = {')
    repeat
        local index = 1
        local chunk = file_in:read(4096)
        local line = column <= 1 and '  ' or ''
        while chunk and index <= #chunk do
            if length > 0 then
                line = line..', '
            end
            if column == 0 or column > 12 then
                line = line..'\n  '
                column = 1
            end
            line = line..string.format('0x%02x', string.byte(chunk, index))
            length = length + 1
            column = column + 1
            index = index + 1
        end
        if line ~= '  ' then
            file_out:write(line)
        end
    until not chunk
    file_out:write('\n};\n'..const..'unsigned int '..var_name..'_len = '..tostring(length)..';\n')

    return false, content
end

local P = {
    ['fs-xxd-i'] = vim_xxd_i,
    ['fs-replace'] = replace,
    ['fs-download'] = download
}

return P
