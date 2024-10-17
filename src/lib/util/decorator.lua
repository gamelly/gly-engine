local function decorator_prefix3(zig, zag, zom, func)
    return function (a, b, c, d, e, f)
        return func(zig, zag, zom, a, b, c, d, e, f)
    end
end

local function decorator_prefix2(zig, zag, func)
    return function (a, b, c, d, e, f)
        return func(zig, zag, a, b, c, d, e, f)
    end
end

local function decorator_prefix1(zig, func)
    return function (a, b, c, d, e, f)
        return func(zig, a, b, c, d, e, f)
    end
end

local P = {
    prefix3 = decorator_prefix3,
    prefix2 = decorator_prefix2,
    prefix1 = decorator_prefix1
}

return P
