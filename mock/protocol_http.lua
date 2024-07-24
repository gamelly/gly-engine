local function http_handler(requests)
    return function (self)
        local request = self.url and requests[self.url]
        local status = request and request.status
        local body = request and request.body

        if type(status) == 'function' then
            status = status(self)
        end
        if type(body) == 'function' then
            body = body(self)
        end

        self.std.http.ok = request and request.ok or false
        self.std.http.status = status
        self.std.http.body = body
        self.std.http.error = nil

        if not self.url then
            self.std.http.error = 'URL not set!'
        elseif not request then
            self.std.http.status = 404    
        end
    end
end

local P = {
    requests = http_handler
}

return P;