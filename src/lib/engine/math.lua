--! @defgroup std
--! @{
--! @defgroup math
--! @{

--! @short abs module
--! @par Equation
--! @f$ |value| @f$
--! @param[in] value
--! @return number
local function abs(value)
    if value < 0 then
        return -value
    end
    return value
end

--! @short clamp
--! @par Equation
--! @f$
--! \begin{cases} 
--! value\_min, & \text{if } value \gt value\_min \\
--! value\_max, & \text{if } value \lt value\_max \\
--! value, & \text{if } value\_min \lt value \lt value\_max 
--! \end{cases}
--! @f$
--! @param[in] value The value to clamp.
--! @param[in] value_min The minimum value that value can be clamped to.
--! @param[in] value_max The maximum value that value can be clamped to.
local function clamp(value, value_min, value_max)
    if value < value_min then
        return value_min
    elseif value > value_max then
        return value_max
    else
        return value
    end
end

--! @short clamp
--! @note similar to @ref clamp but cyclical.
--! @par Equation
--! @f$
--! (value - value\_min) \mod (value\_max - value\_min + 1) + value\_min
--! @f$
--! @param[in] value The value to clamp.
--! @param[in] value_min The minimum value that value can be clamped to.
--! @param[in] value_max The maximum value that value can be clamped to.
local function clamp2(value, value_min, value_max)
    return (value - value_min) % (value_max - value_min + 1) + value_min
end

--! @short periodic cycle
--! @par Equation
--! @f$
--! \begin{cases} 
--! \frac{passed \mod duration}{duration}, & \text{if } (passed \mod duration \neq 0) \\
--! \frac{passed \mod (2 \times duration)}{duration}, & \text{if } (passed \mod duration = 0)
--! \end{cases}
--! @f$
--! @param[in] passed
--! @param[in] duration
--! @retval 0 start of period
--! @retval 0.5 middle of period
--! @retval 1 end of period
--! @par Example
--! @code
--! local anim = std.math.cycle(game.millis, 1000) * 5
--! std.draw.text(x, y + anim, 'hello!')
--! @endcode
local function cycle(passed, duration)
    local endtime = (passed) % duration
    return ((endtime == 0 and (passed % (duration * 2)) or endtime)) / duration
end

--! @short direction
--! @par Equation
--! @f$
--! \begin{cases}
--! -1, & \text{if } |value| \gt \alpha \land value \lt 0 \\
--! 1, & \text{if } |value| \gt \alpha \land value \gt 0 \\
--! 0, & \text{if } |value| \leq \alpha
--! \end{cases}
--! @f$
--! @param[in] value
--! @param[in] alpha @c default=0
--! @retval -1 less than alpha
--! @retval 0 when in alpha
--! @retval 1 greater than alpha
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

--! @brief euclidean distance
--! @par Equation
--! @f$
--! \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}
--! @f$
--! @param[in] x1 The x coordinate of the first point.
--! @param[in] y1 The y coordinate of the first point.
--! @param[in] x2 The x coordinate of the second point.
--! @param[in] y2 The y coordinate of the second point.
--! @return distance between the two points (x1, y1) and (x2, y2).
local function dis(x1,y1,x2,y2)
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end

--! @brief quadratic distance
--! @note this is an optimization of @ref dis but it cannot be used to calculate collisions.
--! @par Equation
--! @f$
--! (x_2 - x_1)^2 + (y_2 - y_1)^2
--! @f$
--! @param[in] x1 The x coordinate of the first point.
--! @param[in] y1 The y coordinate of the first point.
--! @param[in] x2 The x coordinate of the second point.
--! @param[in] y2 The y coordinate of the second point.
--! @return distance between the two points (x1, y1) and (x2, y2).
local function dis2(x1,y1,x2,y2)
    return (x2 - x1) ^ 2 + (y2 - y1) ^ 2
end

--! @brief linear interpolation
--! @par Equation
--! @f$
--! a + \alpha \cdot (b - a)
--! @f$
--! @param[in] a The starting value
--! @param[in] b The ending value
--! @param[in] alpha The interpolation parameter, typically in the range [0, 1].
--! @return The interpolated value between 'a' and 'b' based on 'alpha'.
local function lerp(a, b, alpha)
    return a + alpha * ( b - a )
end 

--! @brief re-maps
--! @li <https://www.arduino.cc/reference/en/language/functions/math/map>
--!
--! @par Equation
--! @f$
--! (value - in\_min) \cdot \frac{(out\_max - out\_min)}{(in\_max - in\_min)} + out\_min
--! @f$
--! @param[in] value The value to be mapped from the input range to the output range.
--! @param[in] in_min The minimum value of the input range.
--! @param[in] in_max The maximum value of the input range.
--! @param[in] out_min The minimum value of the output range.
--! @param[in] out_max The maximum value of the output range.
--! @return The mapped value in the output range corresponding to 'value' in the input range.
local function map(value, in_min, in_max, out_min, out_max)
    return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

--! @short maximum
--! @par Equation
--! @f$
--! \frac{N_1 + N_2 - | N_1 - N_2 |}{2}
--! @f$
local function max(...)
    local args = {...}
    local index = 1
    local value = nil
    local max_value = nil
    
    if #args == 1 then
        args = args[1]
    end

    while index <= #args do
        value = args[index]
        if max_value == nil or value > max_value then
            max_value = value
        end
        index = index + 1
    end

    return max_value
end

--! @short minimum
--! @par Equation
--! @f$
--! \frac{N_1 + N_2 + | N_1 + N_2 |}{2}
--! @f$
local function min(...)
    local args = {...}
    local index = 1
    local value = nil
    local min_value = nil
    
    if #args == 1 then
        args = args[1]
    end

    while index <= #args do
        value = args[index]
        if min_value == nil or value < min_value then
            min_value = value
        end
        index = index + 1
    end

    return min_value
end

--! @brief sawtooth
--! @par Equation
--! @f$
--! \begin{cases}
--! value \times 4, & \text{if } 0 \leq value < 0.25 \\
--! 1 - ((value - 0.25) \times 4), & \text{if } 0.25 \leq value < 0.50 \\
--! ((value - 0.50) \times 4) \times (-1), & \text{if } 0.50 \leq value < 0.75 \\
--! ((value - 0.75) \times 4) - 1, & \text{if } 0.75 \leq value \leq 1 \\
--! \end{cases}
--! @f$
local function saw(value)
    if value < 0.25 then
        return value * 4
    elseif value < 0.50 then
        return 1 - ((value - 0.25) * 4)
    elseif value < 0.75 then
        return ((value - 0.50) * 4) * (-1)
    end
    return ((value - 0.75) * 4) - 1
end

--! @}
--! @}

local P = {
    abs=abs,
    clamp=clamp,
    clamp2=clamp2,
    cycle=cycle,
    dir=dir,
    dis=dis,
    dis2=dis2,
    lerp=lerp,
    map=map,
    max=max,
    min=min,
    saw=saw
}

return P;
