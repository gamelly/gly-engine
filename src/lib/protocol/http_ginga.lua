--! @file src/lib/protocol/http_ginga.lua
--! @li https://www.rfc-editor.org/rfc/rfc2616
--! @todo support redirects 3xx

local function http_connect(self, evt, http)
    local request = 'GET '..self.uri..' HTTP/1.0\r\n'
        ..'Host: '..self.url..'\r\n'
        ..'User-Agent: Mozilla/4.0 (compatible; MSIE 4.0; Windows 95; Win 9x 4.90)\r\n'
        ..'Cache-Control: max-age=0\r\n'
        ..'Content-Length: '..tostring(#self.body_content)..'\r\n'
        ..'Connection: close\r\n\r\n'
        ..self.body_content..'\r\n\r\n'

    event.post({
        class      = 'tcp',
        type       = 'data',
        connection = evt.connection,
        value      = request,
    })

    http.data = ''
end

local function http_headers(self, evt, http)
    http.header = http.data:sub(1, http.header_pos -1)
    local status = http.header:match('^HTTP/%d.%d (%d+) %w*')
    local size = http.header:match('Content%-Length: (%d+)')
    http.content_size = tonumber(size)
    http.status = tonumber(status)
end

local function http_redirect(self, evt, http)
    local protocol, url, uri =  http.header:match('Location: (%w+)://([^/]+)(.*)')
    if protocol == 'https' then
        self.set('ok', false)
        self.set('error', 'HTTPS is not supported!')
    else
        self.set('ok', false)
        self.set('error', 'redirect not implemented!')
    end
    self.resolve()
end

local function http_error(self, evt, http)
    self.set('ok', false)
    self.set('error', evt.error or 'unknown error')
    self.resolve()
end

local function http_data_fast(self, evt, http)
    local status = evt.value:match('^HTTP/%d.%d (%d+) %w*')
    if not status then
        http.callbacks.http_error(self, {error=evt.value}, http)
    else
        status = tonumber(status)
        self.set('status', status)
        self.set('ok', 200 <= status and status < 300)
        self.resolve()
    end
    event.post({
        class      = 'tcp',
        type       = 'disconnect',
        connection = evt.connection,
    })
end

local function http_data(self, evt, http)
    http.data = http.data..evt.value

    if not http.header_pos then
        http.header_pos = http.data:find('\r\n\r\n')
        if http.header_pos then
            http.callbacks.http_headers(self, evt, http)
        end
        if 300 <= http.status and http.status <= 400 then
            http.callbacks.http_redirect(self, evt, http)
        end
    end

    if http.header_pos and (#http.data - http.header_pos) >= http.content_size then
        event.post({
            class      = 'tcp',
            type       = 'disconnect',
            connection = evt.connection,
        })
    end
end

local function http_disconnect(self, evt, http)
    local body = http.data:sub(http.header_pos + 4, #http.data)
    if self.resolve then
        self.set('ok', 200 <= http.status and http.status < 300)
        self.set('status', http.status)
        self.set('body', body)
        http.data = nil
        http.header = nil
        http.status = nil
        http.object = nil
        http.header_pos = nil
        http.content_size = nil
        self.resolve()
    end
end

local function http_handler(self)
    local protocol, location = self.url:match('(%w*)://?(.*)')
    local url, uri = (location or self.url):match('^([^/]+)(.*)$')
    local host, port_str = url:match("^(.-):?(%d*)$")
    local port = tonumber(port_str and #port_str > 0 or 80)

    self.url = url
    self.uri = uri or '/'
    self.application.internal.http.object = self

    if protocol ~= 'http' and location then
        application.internal.http.callbacks.http_error(self, {error='HTTPS is not supported!'})
    else
        self.promise()
        event.post({
            class = 'tcp',
            type  = 'connect',
            host  = host,
            port  = port
        })
    end
end

local function event_loop(std, game, application, evt)
    if evt.class ~= 'tcp' then return end
    local internal_http = application.internal.http
    local self = internal_http.object

    if evt.error then
        application.internal.http.callbacks.http_error(self, evt, internal_http)
    else
        local index = 'http_'..evt.type..self.speed
        application.internal.http.callbacks[index](self, evt, internal_http)
    end
end

local function install(std, game, application)
    application.internal.http = {}
    application.internal.http.callbacks = {
        http_disconnect_fast=http_disconnect,
        http_connect_fast=http_connect,
        http_data_fast=http_data_fast,
        http_disconnect=http_disconnect,
        http_redirect=http_redirect,
        http_connect=http_connect,
        http_headers=http_headers,
        http_error=http_error,
        http_data=http_data
    }

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
