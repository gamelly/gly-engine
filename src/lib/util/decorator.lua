local function decorator_prefix3(zig, zag, zom, func)
    return function (a, b, c, d, e, f)
        return func(zig, zag, zom, a, b, c, d, e, f)
    end
end

local P = {
    prefix3 = decorator_prefix3
}

return P
