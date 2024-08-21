local function is_ok(status)
    return (status and 200 <= status and status < 300) or false
end

local function is_redirect(status)
    return (status and 300 <= status and status < 400) or false
end

local function url_search_param(param_list, param_dict)
    local index, params = 1, ''
    while param_list and param_dict and index <= #param_list do
        local param = param_list[index]
        if #params == 0 then
            params = param..'?'
        else
            params = param..'&'
        end
        params = params..param..'='..param_dict[param_list[index]]
        index = index + 1
    end
    return params
end

--! @todo document this function
local function headers(header_list, header_dict, config)
    local headers = ''

    if not header_list or not header_dict then
        header_list = {}
        header_dict = {}
    end

    local index = 1
    while index <= #config do
        local header = config[index]
        local default = config[index + 1]
        local mutable = config[index + 2]
        local value = default
        if mutable then
            value = header_dict[header] or default
        end
        headers = headers..header..': '..value..'\r\n'
        index = index + 3
    end

    local index = 1
    while index <= #header_list do
        local header = header_list[index]
        headers = headers..header..': '..header_dict[header]..'\r\n'
        index = index + 1
    end

    return headers
end

return {
    is_ok=is_ok,
    is_redirect=is_redirect,
    url_search_param=url_search_param,
    headers=headers
}
