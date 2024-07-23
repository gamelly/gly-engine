local function http_handler(self)
    local cmd = 'curl -L --silent --insecure -w "%{http_code}" '
    local protocol = self.method == 'HEAD' and '--HEAD ' or '-X '..self.method..' '
    local handle = io.popen(cmd..protocol..self.url)
    local stdout = handle:read("*a")
    local ok, stderr = handle:close()
    local index = stdout:find("[^\n]*$") or 1
    local body = stdout:sub(1, index - 1)
    local status = tonumber(stdout:sub(index))

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
end

local P = {
    handler = http_handler
}

return P
