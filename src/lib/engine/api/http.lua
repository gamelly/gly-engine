local zeebo_pipeline = require('src/lib/util/pipeline')

--! @defgroup std
--! @{
--! @defgroup http
--! @pre require @c http
--! @{
--!
--! @page http_get GET
--! 
--! @code{.java}
--! std.http.get('https://api.github.com/zen')
--!     :run()
--! @endcode
--!
--! @page http_post POST
--! 
--! @code{.java}
--! std.http.post('https://example.com.br')
--!     :body('{"foo": "bar"}')
--!     :run()
--! @endcode
--!
--! @page http_request Http requests
--! 
--! @li @b std.http.get
--! @li @b std.http.head
--! @li @b std.http.post
--! @li @b std.http.put
--! @li @b std.http.delete
--! @li @b std.http.patch
--! 
--! @page http_response Http responses
--!
--! @li local handlers
--! @code
--! std.http.get('http://pudim.com.br')
--!     :success(function()
--!         print('2xx callback')
--!     end)
--!     :failed(function()
--!         print('4xx / 5xx callback')
--!     end)
--!     :error(function()
--!         print('eg. to many redirects')
--!     end)
--!     :run()
--! @endcode
--! @li global handler
--! @code{.java}
--! local function http(std, game)
--!     if std.http.error then
--!         print('eg. https is not supported')
--!     end
--!     if std.http.ok then
--!         print('2xx status')
--!     end
--!     if std.http.status > 400 then
--!         print('2xx / 5xx status')
--!     end
--! end
--! @endcode

--! @short reduced response
--! @hideparam self
--! @brief disconnect when receiving status
local function fast(self)
    self.speed = '_fast'
    return self
end

--! @hideparam self
local function body(self, content)
    self.body_content=content
    return self
end

--! @hideparam self
local function param(self, name, value)
    local index = #self.param_list + 1
    self.param_list[index] = name
    self.param_dict[name] = value
    return self
end

--! @hideparam self
local function header(self, name, value)
    local index = #self.header_list + 1
    self.header_list[index] = name
    self.header_dict[name] = value
    return self
end

--! @hideparam self
local function success(self, handler_func)
    self.success_handler = handler_func
    return self
end

--! @hideparam self
local function failed(self, handler_func)
    self.failed_handler = handler_func
    return self
end

--! @hideparam self
--! @rename_func error
local function http_error(self, handler_func)
    self.error_handler = handler_func
    return self
end

--! @}
--! @}

--! @cond
local function request(method, std, engine, protocol)
    local callback_handler = function()
        if std.node then
            std.node.emit(engine.current, 'http')
        elseif engine.current.callbacks.http then
            engine.current.callbacks.http(std, engine.current.data)
        end
    end

    return function (url)
        if protocol.has_callback then
            engine.http_count = engine.http_count + 1
        end

        local game = engine.current.data

        local self = {
            -- content
            id = engine.http_count,
            url = url,
            speed = '',
            method = method,
            body_content = '',
            header_list = {},
            header_dict = {},
            param_list = {},
            param_dict = {},
            success_handler = function (std, game) end,
            failed_handler = function (std, game) end,
            error_handler = function (std, game) end,
            -- functions
            fast = fast,
            body = body,
            param = param,
            header = header,
            success = success,
            failed = failed,
            error = http_error,
            run = zeebo_pipeline.run,
        }

        self.promise = function()
            zeebo_pipeline.stop(self)
        end

        self.resolve = function()
            zeebo_pipeline.resume(self)
        end

        self.set = function (key, value)
            std.http[key] = value
        end

        self.pipeline = {
            -- eval
            function()
                if protocol.has_callback then engine.http_requests[self.id] = self end
                protocol.handler(self, self.id)
            end,
            -- callbacks
            function()
                -- global handler
                callback_handler(std, game)
                -- local handlers
                if std.http.ok then
                    self.success_handler(std, game)
                elseif std.http.error or not std.http.status then
                    self.error_handler(std, game)
                else
                    self.failed_handler(std, game)
                end
            end,
            -- clean http
            function ()
                std.http.ok = nil
                std.http.body = nil
                std.http.error = nil
                std.http.status = nil
            end,
            -- reset request
            function()
                if protocol.has_callback then engine.http_requests[self.id] = nil end
                zeebo_pipeline.reset(self)
            end
        }

        return self
    end
end
--! @endcond

local function install(std, engine, protocol)
    assert(protocol.handler, 'missing protocol handler')

    std.http = std.http or {}
    std.http.get=request('GET', std, engine, protocol)
    std.http.head=request('HEAD', std, engine, protocol)
    std.http.post=request('POST', std, engine, protocol)
    std.http.put=request('PUT', std, engine, protocol)
    std.http.delete=request('DELETE', std, engine, protocol)
    std.http.patch=request('PATCH', std, engine, protocol)

    if protocol.has_callback then
        engine.http_count = 0
        engine.http_requests = {}
    end

    if protocol.install then
        protocol.install(std, engine)
    end
end

local P = {
    install=install
}

return P
