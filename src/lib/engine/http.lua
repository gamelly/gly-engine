local zeebo_pipeline = require('src/lib/util/pipeline')

--! @defgroup std
--! @{
--! @defgroup http
--! @pre require @c http
--! @{

--! @short reduced response
--! @brief disconnect when receiving status
local function fast(self)
    self.speed = '_fast'
    return self
end

local function body(self, content)
    self.body_content=content
    return self
end

local function param(self, name, value)
    local index = #self.param_list + 1
    self.param_list[index] = name
    self.param_dict[name] = value
    return self
end

local function header(self, name, value)
    local index = #self.header_list + 1
    self.header_list[index] = name
    self.header_dict[name] = value
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
        local self = {
            -- content
            url = url,
            speed = '',
            method = method,
            body_content = '',
            header_list = {},
            header_dict = {},
            param_list = {},
            param_dict = {},
            callback_handler = callback_handler,
            success_handler = function (std, game) end,
            failed_handler = function (std, game) end,
            error_handler = function (std, game) end,
            -- objects
            std = std,
            game = game,
            application = application,
            -- functions
            fast = fast,
            body = body,
            param = param,
            header = header,
            success = success,
            failed = failed,
            error = error,
            run = zeebo_pipeline.run,
            -- internal
            protocol_handler = protocol_handler
        }

        self.promise = function()
            zeebo_pipeline.stop(self)
        end

        self.resolve = function()
            zeebo_pipeline.resume(self)
        end

        self.set = function (key, value)
            self.std.http[key] = value
        end

        self.pipeline = {
            -- eval
            function()
                self:protocol_handler()
            end,
            -- callbacks
            function()
                -- global handler
                self.callback_handler(self.std, self.game)
                -- local handlers
                if self.std.http.ok then
                    self.success_handler(self.std, self.game)
                elseif self.std.http.error or not self.std.http.status then
                    self.error_handler(self.std, self.game)
                else
                    self.failed_handler(self.std, self.game)
                end
            end,
            -- clean http
            function ()
                self.std.http.ok = nil
                self.std.http.body = nil
                self.std.http.error = nil
                self.std.http.status = nil
            end,
            -- reset request
            function()
                zeebo_pipeline.reset(self)
            end
        }

        return self
    end
end
--! @endcond

local function install(std, game, application, protocol)
    local protocol_handler = protocol.handler
    local event = nil
    
    std.http = std.http or {}
    std.http.get=request('GET', std, game, application, protocol_handler)
    std.http.head=request('HEAD', std, game, application, protocol_handler)
    std.http.post=request('POST', std, game, application, protocol_handler)
    std.http.put=request('PUT', std, game, application, protocol_handler)
    std.http.delete=request('DELETE', std, game, application, protocol_handler)
    std.http.patch=request('PATCH', std, game, application, protocol_handler)
    
    if protocol.install then
        local m = protocol.install(std, game, application)
        event = m and m.event
    end

    return {
        event=event,
        std={http=std.http}
    }
end

local P = {
    install=install
}

return P
