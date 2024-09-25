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

local P = {
    ['fs-replace'] = replace,
    ['fs-download'] = download
}

return P
