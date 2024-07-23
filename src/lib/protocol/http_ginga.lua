local function http_handler(self)
    tcp.execute(function ()
        local uri, port = self.url:find("^(.-):?(%d*)$")
        tcp.connect(uri, tonumber(port or 80))
        tcp.send('get /')


        self.std.http.ok = ok and 200 <= status and status < 300
        self.std.http.error = not ok and stderr
        self.std.http.status = status
        self.std.http.body = body

        if not ok then
            self.error_handler(self.std, self.game)
        elseif 200 <= status and status < 300 then
            self.success_handler(self.std, self.game)
        else
            self.failed_handler(self.std, self.game)
        end
    end)
end

local P = {
    handler = http_handler
}

return P