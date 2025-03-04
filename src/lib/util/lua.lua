local function has_support_utf8()
    if jit then
        return true
    end

    if tonumber(_VERSION:match('Lua 5.(%d+)')) >= 3 then
        return true
    end

    return false
end

local function eval(script)
    local loader = loadstring or load
    if not loader then
        error('eval not allowed')
    end
    local ok, chunk = pcall(loader, script)
    if not ok then
        return false, chunk
    end
    if type(chunk) ~= 'function' then
        return false, 'failed to eval'
    end
    return pcall(chunk)
end

local P = {
    eval = eval,
    has_support_utf8=has_support_utf8
}

return P
