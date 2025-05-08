local http_util = require('src/lib/util/http')
local base_url = 'http://localhost:44642/dtv/current-service/ginga/persistent'
local requests = {}
local headers = {
    ['User-Agent'] = http_util.get_user_agent()
}

local function storage_set(key, value, promise, resolve)
    local self = {promise=promise,resolve=resolve}
    local session = tonumber(tostring(self):match("0x(%x+)$"), 16)
    local uri = base_url..'?var-name=channel.'..key
    local body = '{"varValue": "'..value..'"}'

    requests[session] = self

    self.promise()
    event.post({
        class = 'http',
        type = 'request',
        method = 'post',
        uri = uri,
        body = body,
        headers = headers,
        session = session
    })
end

local function storage_get(key, push, promise, resolve)
    local self = {push=push,promise=promise,resolve=resolve,body=''}
    local session = tonumber(tostring(self):match("0x(%x+)$"), 16)
    local uri = base_url..'/channel.'..key..'?var-name=channel.'..key

    requests[session] = self

    self.promise()
    event.post({
        class = 'http',
        type = 'request',
        method = 'get',
        uri = uri,
        headers = headers,
        session = session
    })
end

local function callback(std, engine, evt)
    if evt.class ~= 'http' or not evt.session then return end
    
    local self = requests[evt.session]

    if self then
        if not self.body then
            requests[evt.session] = nil
            return self.resolve()
        end

        if evt.body then
            self.body = self.body..evt.body
        end
       
        if evt.error or evt.code ~= 200 then
            requests[evt.session] = nil
            return self.resolve()
        end

        if evt.finished then
            requests[evt.session] = nil
            local data = std.json.decode(self.body)
            self.push(data[1] and data[1].value or data.value or '')
            return self.resolve()
        end
    end
end

local function install(std)
    if not std.json then
        error('require json')
    end
    std.bus.listen_std_engine('ginga', callback)
end

local P = {
    install = install,
    get = storage_get,
    set = storage_set,
}

return P
