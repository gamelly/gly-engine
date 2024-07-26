local headers_separators = {
    '\n\n',
    '\r\n\r\n',
    '\n\r\n\r'
}

local function event_loop(evt, std, game, application)
    if evt.class ~= 'tcp' then return end
    local self = application.internal.http_object
    
    if not evt.connection and evt.type ~= 'disconnect' then
        self.set('ok', false)
        self.set('error', 'broken connector')
        self.resolve()
    elseif evt.error then
        self.set('ok', false)
        self.set('error', evt.error)
        self.resolve()
    elseif evt.type == 'connect' then
        self.data = ''
        local request = 'GET '..self.uri..' HTTP/1.0\n'
            ..'Host: '..self.url..'\n'
            ..'User-Agent: Mozilla/4.0 (compatible; MSIE 4.0; Windows 95; Win 9x 4.90)\n'
            ..'Cache-Control: max-age=0\n'
            ..'Connection: close\n\n'
        event.post({
            class      = 'tcp',
            type       = 'data',
            connection = evt.connection,
            value      = request,
        })
    elseif evt.type == 'data' then
        self.data = self.data..evt.value
        if not self.content_headers then
            local index = 1
            local pos_end_headers = nil
            local size_end_headers = nil
            while not pos_end_headers and index <= #headers_separators do
                pos_end_headers = self.data:find(headers_separators[index])
                size_end_headers = #headers_separators[index]
                index = index + 1
            end
            if pos_end_headers then
                self.content_headers = self.data:sub(1, pos_end_headers - 1)
            end
            if (#self.data - #self.content_headers - size_end_headers) == 294 then
                event.post({
                    class      = 'tcp',
                    type       = 'disconnect',
                    connection = evt.connection,
                })
            end
        end
    elseif evt.type == 'disconnect' then
        print('bye!') 
    end

end

local function http_handler(self)
    local host, port_str = self.url:match("^(.-):?(%d*)$")
    local port = tonumber(port_str and #port_str > 0 or 80)

    event.post({
        class = 'tcp',
        type  = 'connect',
        host  = host,
        port  = port
    })

    self.application.internal.http_object = self
    self.promise()
end

local function install(std, game, application)
    local index = #application.internal.event_loop + 1
    application.internal.event_loop[index] = function (evt)
        event_loop(evt, std, game, application)    
    end
    return {
        loop=application.internal.event_loop[index]
    }
end

local P = {
    handler = http_handler,
    install = install
}

return P
