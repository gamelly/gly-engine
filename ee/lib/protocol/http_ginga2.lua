local http_util = require('src/lib/util/http')
local ginga_support = require('ee/lib/util/support')
local request_dict = {}
local data_dict = {}

local function handler(self)
    local uri = self.url..http_util.url_search_param(self.param_list, self.param_dict)
    local allow_body = self.method ~= 'GET' and self.method ~= 'HEAD'
    local method = string.lower(self.method)
    local body = allow_body and self.body
    local headers = self.header_dict
    local session = self.id

    data_dict[session] = ''
    request_dict[session] = self

    self.promise()
    event.post({
        class = 'http',
        type = 'request',
        method = method,
        uri = uri,
        headers = headers,
        body = body,
        session = session
    })
end

local function callback(evt)
    if evt.class ~= 'http' then return end
    local session = evt.session
    local self = request_dict[session]

    if evt.error and #evt.error > 0 then
        self.set('error', evt.error)
    end

    if evt.headers then
        -- todo
    end

    if evt.code then
        self.set('ok', http_util.is_ok(evt.code))
        self.set('status', evt.code)
    end

    if evt.body then
        data_dict[session] = data_dict[session]..evt.body
    end

    if evt.finished or evt.error then
        self.set('body', data_dict[session])
        request_dict[session] = nil
        data_dict[session] = nil
        self.resolve()
    end
end

local function install(std)    
    if not ginga_support.class('http') then
        error('old device!')
    end
    httptunado = true
    std.bus.listen('ginga', callback)
end

local P = {
    install = install,
    handler = handler,
    has_callback = true,
    has_ssl = true
}

return P
