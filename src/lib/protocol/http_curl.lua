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

    local handle = io and io.popen and io.popen(cmd..protocol..headers..self.url..self.uri)

    if handle then
        local stdout = handle:read("*a")
        local ok, stderr = handle:close()
        local index = stdout:find("[^\n]*$") or 1
        local status = tonumber(stdout:sub(index))
        if not ok then
            self.std.http.ok = false
            self.std.http.error = stderr or stdout or 'unknown error!'
        else
            self.std.http.ok = 200 <= status and status < 300
            self.std.http.body = stdout:sub(1, index - 1)
            self.std.http.status = status
        end        
    else 
        self.std.http.ok = false
        self.std.http.error = 'failed to spawn process!'
    end
end

local P = {
    handler = http_handler
}

return P
