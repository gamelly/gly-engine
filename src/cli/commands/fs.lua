local function replace(args)
    return false, 'not implemented!'
end

local function download(args)
    return false, 'not implemented!'
end

local P = {
    ['fs-replace'] = replace,
    ['fs-download'] = download
}

return P
