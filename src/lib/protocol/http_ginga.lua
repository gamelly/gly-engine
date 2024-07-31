--! @file src/lib/protocol/http_ginga.lua
--! @li https://www.rfc-editor.org/rfc/rfc2616
--!
--! @todo support redirects 3xx
--! @todo support custom user-agent
--! @todo support request headers
--! @todo support URI params
--!
--! @par Contexts
--! @startjson
--! {
--!    "by_host": {
--!       "pudim.com.br": [
--!         {
--!          "url": "pudim.com.br/"
--!         }
--!       ],
--!       "example.com": [
--!         {
--!          "url": "example.com/foo"
--!         },
--!         {
--!          "url": "example.com/bar"
--!         }
--!       ]
--!    },
--!    "by_connection": {
--!      "connector.id.1" : {
--!         "url": "example.com/zig"
--!      },
--!      "connector.id.2" : {
--!         "url": "example.com/zag"
--!      }
--!    }
--! }
--! @endjson

--! @param [in/out] self
local function http_connect(self)
    local request = 'GET '..self.p_uri..' HTTP/1.0\r\n'
        ..'Host: '..self.p_host..'\r\n'
        ..'User-Agent: Mozilla/4.0 (compatible; MSIE 4.0; Windows 95; Win 9x 4.90)\r\n'
        ..'Cache-Control: max-age=0\r\n'
        ..'Content-Length: '..tostring(#self.body_content)..'\r\n'
        ..'Connection: close\r\n\r\n'
        ..self.body_content..'\r\n\r\n'

    event.post({
        class      = 'tcp',
        type       = 'data',
        connection = self.evt.connection,
        value      = request,
    })
end

--! @param [in/out] self
local function http_headers(self)
    self.p_header = self.p_data:sub(1, self.p_header_pos -1)
    self.p_status = tonumber(self.p_header:match('^HTTP/%d.%d (%d+) %w*'))
    self.p_content_size = tonumber(self.p_header:match('Content%-Length: (%d+)'))
end

--! @param [in/out] self
local function http_redirect(self)
    local protocol, url, uri =  self.p_header:match('Location: (%w+)://([^/]+)(.*)')
    if protocol == 'https' and self.p_host == url then
        self.evt.error = 'HTTPS is not supported!'
        self.application.internal.http.callbacks.http_error(self)
    else
        self.evt.error = 'redirect not implemented!'
        self.application.internal.http.callbacks.http_error(self)
    end
end

--! @param [in/out] self
local function http_error(self)
    self.set('ok', false)
    self.set('error', self.evt and self.evt.error or 'unknown error')
    self.resolve()
end

--! @param [in/out] self
local function http_data_fast(self)
    local evt = self.evt
    local status = self.evt.value:match('^HTTP/%d.%d (%d+) %w*')
    if not status then
        self.evt = {error = self.evt.value}
        self.application.internal.http.callbacks.http_error(self)
    else
        self.p_status = tonumber(status)
        self.application.internal.http.callbacks.http_resolve(self)
    end
    event.post({
        class      = 'tcp',
        type       = 'disconnect',
        connection =  evt.connection,
    })
end

--! @param [in/out] self
local function http_data(self)
    self.p_data = self.p_data..self.evt.value

    if not self.p_header_pos then
        self.p_header_pos = self.p_data:find('\r\n\r\n')
        if self.p_header_pos then
            self.application.internal.http.callbacks.http_headers(self)
        end
        if 300 <= self.p_status and self.p_status < 400 then
            self.application.internal.http.callbacks.http_redirect(self)
            return
        end
    end

    if self.p_header_pos and (#self.p_data - self.p_header_pos) >= self.p_content_size then
        local evt = self.evt
        self.application.internal.http.context.remove(self.evt)
        self.application.internal.http.callbacks.http_resolve(self)
        event.post({
            class      = 'tcp',
            type       = 'disconnect',
            connection =  evt.connection,
        })
    end
end

--! @param [in/out] self
local function http_resolve(self)
    local body = ''
    if #self.speed == 0 then
        body = self.p_data:sub(self.p_header_pos + 4, #self.p_data)
    end
    self.set('ok', 200 <= self.p_status and self.p_status < 300)
    self.set('status', self.p_status)
    self.set('body', body)
    self.evt = nil
    self.p_url = nil
    self.p_uri = nil
    self.p_host = nil
    self.p_status = nil
    self.p_content_size = nil
    self.p_header = nil
    self.p_header_pos = nil
    self.p_data = nil
    self.resolve()
end

--! @param [in/out] self
local function http_disconnect(self)

end

--! @param [in/out] self
local function http_handler(self)
    local protocol, location = self.url:match('(%w*)://?(.*)')
    local url, uri = (location or self.url):match('^([^/]+)(.*)$')
    local host, port_str = url:match("^(.-):?(%d*)$")
    local port = tonumber(port_str and #port_str > 0 and port_str or 80)

    self.p_url = url
    self.p_uri = uri or '/'
    self.p_host = host
    self.p_data = ''

    if protocol ~= 'http' and location then
        self.evt = { error = 'HTTPS is not supported!' }
        self.application.internal.http.callbacks.http_error(self)
    else
        self.application.internal.http.context.push(self)
        self.promise()
        event.post({
            class = 'tcp',
            type  = 'connect',
            host  = host,
            port  = port
        })
    end
end

--! @param [in] self
local function context_push(self, contexts)
    local host = self.p_host
    if not contexts.by_host[host] then
        contexts.by_host[host] = {}
    end
    local index = #contexts.by_host[host] + 1
    contexts.by_host[host][index] = self
end

--! @param [in] evt
local function context_pull(evt, contexts)
    local host = evt.host
    local connection = evt.connection
    local index = host and contexts.by_host[host] and #contexts.by_host[host]

    if evt.type == 'connect' and host and contexts.by_host[host] then
        local index = #contexts.by_host[host]
        local self = contexts.by_host[host][index]
        if evt.error then
            self.evt = {type = 'error', error = evt.error}
            contexts.by_host[host][index] = nil
            return self
        end
        self.evt = evt
        contexts.by_connection[connection] = self
        contexts.by_host[host][index] = nil
        return self
    elseif evt.type == 'disconnect' then
        local self = {speed=''}
        if host and index and contexts.by_host[host][index] then
            self = contexts.by_host[host][index]
            contexts.by_host[host][index] = nil
        end
        if connection and contexts.by_connection[connection] then
            self = contexts.by_connection[connection]
            contexts.by_connection[connection] = nil
        end
        if evt.error then
            self.evt = {type = 'error', error = evt.error}
        else
            self.evt = evt
        end
        return self
    elseif connection and contexts.by_connection[connection] then
        local self = contexts.by_connection[connection]
        if evt.error then
            self.evt = {type = 'error', error = evt.error}
            contexts.by_connection[connection] = nil
            return self
        end
        self.evt = evt
        return self
    end
end

--! @param [in] evt
local function context_remove(evt, contexts)
    local connection = evt.connection

    if connection then
        contexts.by_connection[connection] = nil
    end
end

local function event_loop(std, game, application, evt)
    if evt.class ~= 'tcp' then return end

    local self = application.internal.http.context.pull(evt)

    if self then
        local index = 'http_'..self.evt.type..self.speed
        application.internal.http.callbacks[index](self)
    end
end

local function install(std, game, application)
    local contexts = {
        by_host={},
        by_connection={}
    }
    application.internal = application.internal or {}
    application.internal.http = {}
    application.internal.http.context = {
        push = function(self) context_push(self, contexts) end,
        pull = function(evt) return context_pull(evt, contexts) end,
        remove = function (evt) context_remove(evt, contexts) end
    }
    application.internal.http.callbacks = {
        http_disconnect_fast=http_disconnect,
        http_connect_fast=http_connect,
        http_data_fast=http_data_fast,
        http_disconnect=http_disconnect,
        http_redirect=http_redirect,
        http_connect=http_connect,
        http_headers=http_headers,
        http_resolve=http_resolve,
        http_error=http_error,
        http_data=http_data
    }

    application.internal.event_loop = application.internal.event_loop or {}
    local index = #application.internal.event_loop + 1
    application.internal.event_loop[index] = function (evt)
        event_loop(std, game, application, evt)    
    end

    return http_handler
end

local P = {
    handler = http_handler,
    install = install
}

return P
