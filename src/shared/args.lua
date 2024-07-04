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

local function shared_args_param(args, args_get, position, default)
    local index = 1
    local count = 1
    local args_get2 = {}
    local value = default   
    
    while index <= #args_get do
        args_get2[args_get[index]] = true
        index = index + 1
    end
    
    index = 1
    while index <= #args do
        local arg = args[index]
        local param = args[index - 1]
        if arg:sub(1, 2) ~= '--' then
            if index <= 1 or (param and not (param:sub(1, 2) == '--' and args_get2[param:sub(3, #param)])) then
                if position == count then
                    value = arg
                end
                count = count + 1
            end
        end 
        index = index + 1
    end

    return value
end

local P = {
    has = shared_args_has,
    get = shared_args_get,
    param = shared_args_param
}

return P
