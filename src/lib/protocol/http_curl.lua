local http_util = require('src/lib/util/http')

local function http_handler(self)
    local params = http_util.url_search_param(self.param_list, self.param_dict)
    local command, cleanup = http_util.create_request(self.method, self.url..params)
        .add_custom_headers(self.header_list, self.header_dict)
        .add_body_content(self.body_content)
        .to_curl_cmd()

    local handle = io and io.popen and io.popen(command)

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
            self.std.http.body = stdout:sub(1, index - 2)
            self.std.http.status = status
        end        
    else 
        self.std.http.ok = false
        self.std.http.error = 'failed to spawn process!'
    end

    cleanup()
end

local P = {
    handler = http_handler
}

return P
