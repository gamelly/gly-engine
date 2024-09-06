local function has_support_utf8()
    if jit then
        return true
    end

    if tonumber(_VERSION:match('Lua 5.(%d+)')) >= 3 then
        return true
    end

    return false
end

local P = {
    has_support_utf8=has_support_utf8
}

return P
