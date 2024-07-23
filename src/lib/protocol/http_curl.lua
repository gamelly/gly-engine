local function http_handler(self)
    local index = 1
    local cmd = 'curl -L --silent --insecure -w "\n%{http_code}" '
    local protocol = self.method == 'HEAD' and '--HEAD' or '-X '..self.method
    
    local headers, index = ' ', 1
    while self.header_name_list and index <= #self.header_name_list do
        headers = headers..'-H "'..self.header_name_list[index]..': '
        headers = headers..self.header_value_list[index]..'" '
        index = index + 1
    end

    local handle = io.popen(cmd..protocol..headers..self.url)

    if handle then
        local stdout = handle:read("*a")
        local ok, stderr = handle:close()
        local index = stdout:find("[^\n]*$") or 1
        local status = tonumber(stdout:sub(index))
        self.std.http.error = not ok and stderr
        self.std.http.body = stdout:sub(1, index - 1)
        self.std.http.status = ok and status or nil
        self.std.http.ok = ok and status and 200 <= status and status < 300
    end

    if self.std.http.ok then
        self.success_handler(self.std, self.game)
    elseif self.std.http.error or not self.std.http.status then
        self.error_handler(self.std, self.game)
    else
        self.failed_handler(self.std, self.game)
    end
end

local P = {
    handler = http_handler
}

return P
