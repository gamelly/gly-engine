local http_util = require('src/lib/util/http')

local function http_handler(self)
    local index = 1
    local cmd = 'curl -L \x2D\x2Dsilent \x2D\x2Dinsecure -w "\n%{http_code}" '
    local protocol = self.method == 'HEAD' and '\x2D\x2DHEAD' or '-X ' .. self.method
    local params = http_util.url_search_param(self.param_list, self.param_dict)
    
    local headers, index = ' ', 1

    while self.header_list and index <= #self.header_list do
        local header = self.header_list[index]
        headers = headers..'-H "'..header..': '
        headers = headers..self.header_dict[self.header_list[index]]..'" '
        index = index + 1
    end

    local body = ''
    if self.method == 'POST' and self.body_content then
        body = '-d \''..self.body_content..'\' '
    end

    local function toCurlCommand()
        local curlCommand = cmd..protocol..headers..body..self.url..params
        
        local function cleanup()
            -- closure
        end

        return curlCommand, cleanup
    end

    local handle = io and io.popen and io.popen(toCurlCommand())
    
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
