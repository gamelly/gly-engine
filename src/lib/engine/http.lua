local zeebo_pipeline = require('src/lib/engine/pipeline')

--! @defgroup std
--! @{
--! @defgroup http
--! @pre require @c http
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

--! @}
--! @}

--! @cond
local function request(method, std, game, application, protocol_handler)
    local callback_handler = application and application.callbacks and application.callbacks.http

    if not callback_handler then
        callback_handler = function() end
    end

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
            callback_handler = callback_handler,
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
                local response = http_object:protocol_handler()
                if response and #response > 0 then
                    http_object.std.http.ok = response[1]
                    http_object.std.http.body = response[2]
                    http_object.std.http.status = response[3]
                    http_object.std.http.error = response[4]
                end
            end,
            -- callbacks
            function()
                -- global handler
                http_object.callback_handler(http_object.std, http_object.game)
                -- local handlers
                if http_object.std.http.ok then
                    http_object.success_handler(http_object.std, http_object.game)
                elseif http_object.std.http.error or not http_object.std.http.status then
                    http_object.error_handler(http_object.std, http_object.game)
                else
                    http_object.failed_handler(http_object.std, http_object.game)
                end
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
--! @endcond

local function install(std, game, application, protocol)
    local protocol_handler = protocol.handler
    std = std or {}
    std.http = std.http or {}
    std.http.get=request('GET', std, game, application, protocol_handler)
    std.http.head=request('HEAD', std, game, application, protocol_handler)
    std.http.post=request('POST', std, game, application, protocol_handler)
    std.http.put=request('PUT', std, game, application, protocol_handler)
    std.http.delete=request('DELETE', std, game, application, protocol_handler)
    std.http.patch=request('PATCH', std, game, application, protocol_handler)
    return std.http
end

local P = {
    install=install
}

return P
