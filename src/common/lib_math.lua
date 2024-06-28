local function clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

local function dir(value, alpha)
    alpha = alpha or 0
    if value < -alpha then
        return -1
    elseif value > alpha then
        return 1
    else
        return 0
    end
end

local function dis(x1,y1,x2,y2)
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end

local function abs(value)
    if value < 0 then
        return -value
    end
    return value
end

local function saw(x)
    if x < 0.25 then
        return x * 4
    elseif x < 0.50 then
        return 1 - ((x - 0.25) * 4)
    elseif x < 0.75 then
        return ((x - 0.50) * 4) * (-1)
    end
    return ((x - 0.75) * 4) - 1
end

local function lerp(a, b, alpha)
    return a + alpha * ( b - a )
end 

local function map(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local function cycle(passed, duration)
    local endtime = (passed) % duration
    return ((endtime == 0 and (passed % (duration * 2)) or endtime)) / duration
end

local P = {
    cycle=cycle,
    clamp=clamp,
    lerp=lerp,
    abs=abs,
    map=map,
    saw=saw
}

return P;
