local function shared_args_get(args, arg, default)
    local index = 1
    local value = default    
    while index <= #args do
        local param = args[index]
        local nextparam = args[index + 1]
        if param:sub(1, 2) == '--' and param:sub(3, #param) == arg and nextparam and nextparam:sub(1, 2) ~= '--' then
            value = nextparam
        end 
        index = index + 1
    end
    return value
end

local function shared_args_has(args, arg)
    local index = 1
    while index <= #args do
        local param = args[index]
        if param:sub(1, 2) == '--' and param:sub(3, #param) == arg then
            return true
        end 
        index = index + 1
    end
    return false
end

local P = {
    has = shared_args_has,
    get = shared_args_get
}

return P
