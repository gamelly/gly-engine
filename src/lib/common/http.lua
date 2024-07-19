local zeebo_pipeline = require('std/lib/common/pipeline')

--! @defgroup std
--! @{
--! @defgroup http
--! @{
local function body(self, content)
    return self
end

local function param(self, name, value)
    return self
end

local function success(self, handler_func)
    return self
end

local function failed(self, handler_func)
    return self
end

local function request(method, std, game, protocol_handler)
    function (url)
        local http_object = {
            -- content
            url = url,
            body_content = '',
            param_name_list = {},
            param_value_list = {},
            success_handler = function () end,
            failed_handler = function () end,
            -- objects
            std = std,
            game = game,
            -- functions
            body = body,
            param = param,
            success = success,
            failed = failed,
            pipe = zeebo_pipeline.pipe,
            run = zeebo_pipeline.run
            -- internal
            protocol_handler = protocol_handler,
            state = 1
        }
    end
end

--! @}
--! @}

--! @cond
local function install(std, game, protocol_handler)
    local methods = {
        get=request('GET', std, game, protocol_handler),
        head=request('HEAD', std, game, protocol_handler),
        post=request('POST', std, game, protocol_handler),
        put=request('PUT' std, game, protocol_handler),
        delete=request('DELETE', std, game, protocol_handler),
        patch=request('PATCH', std, game, protocol_handler)
    }

    std.http = method
end
--! @endcond

local P = {
    install=install
}

return P
