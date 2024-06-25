local function clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

local function abs(value)
    if value < 0 then
        return -value
    end
    return value
end

local P = {
    clamp=clamp,
    abs=abs
}

return P;
