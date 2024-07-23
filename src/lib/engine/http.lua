local zeebo_pipeline = require('src/lib/engine/pipeline')

--! @defgroup std
--! @{
--! @defgroup http
--! @{
local function body(self, content)
    self.body_content=content
    return self
end

local function param(self, name, value)
    local index = #self.param_name_list + 1
    self.param_name_list[index] = name
    self.param_value_list[index] = value
    return self
end

local function header(self, name, value)
    local index = #self.header_name_list + 1
    self.header_name_list[index] = name
    self.header_value_list[index] = value
    return self
end

local function success(self, handler_func)
    self.success_handler = handler_func
    return self
end

local function failed(self, handler_func)
    self.failed_handler = handler_func
    return self
end

local function error(self, handler_func)
    self.error_handler = handler_func
    return self
end

local function request(method, std, game, protocol_handler)
    return function (url)
        local http_object = {
            -- content
            url = url,
            method = method,
            body_content = '',
            header_name_list = {},
            header_value_list = {},
            param_name_list = {},
            param_value_list = {},
            success_handler = function () end,
            failed_handler = function () end,
            error_handler = function () end,
            -- objects
            std = std,
            game = game,
            -- functions
            body = body,
            param = param,
            header = header,
            success = success,
            failed = failed,
            error = error,
            pipe = zeebo_pipeline.pipe,
            run = zeebo_pipeline.run,
            -- internal
            protocol_handler = protocol_handler
        }

        http_object.pipeline = {
            -- eval
            function()
                http_object:protocol_handler()
            end,
            -- clean http
            function ()
                http_object.std.http.ok = nil
                http_object.std.http.body = nil
                http_object.std.http.error = nil
                http_object.std.http.status = nil
            end,
            -- clean gc
            function()
                http_object.url = nil
                http_object.body_content = nil
                http_object.param_name_list = nil
                http_object.param_value_list = nil
                http_object.header_name_list = nil
                http_object.header_value_list = nil
                http_object.success_handler = nil
                http_object.failed_handler = nil
                http_object.std = nil
                http_object.game = nil
                http_object.body = nil
                http_object.param = nil
                http_object.success = nil
                http_object.failed = nil
                http_object.pipe = nil
                http_object.run = nil
                http_object.pipeline = nil
                http_object.before_pipeline = nil
                http_object.protocol_handler = nil
                http_object.state = nil
            end
        }

        return http_object
    end
end

--! @}
--! @}

--! @cond
local function install(std, game, protocol_handler)
    std = std or {}
    std.http = std.http or {}
    std.http.get=request('GET', std, game, protocol_handler)
    std.http.head=request('HEAD', std, game, protocol_handler)
    std.http.post=request('POST', std, game, protocol_handler)
    std.http.put=request('PUT', std, game, protocol_handler)
    std.http.delete=request('DELETE', std, game, protocol_handler)
    std.http.patch=request('PATCH', std, game, protocol_handler)
    return std.http
end
--! @endcond

local P = {
    install=install
}

return P
