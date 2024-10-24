local http_util = require('src/lib/util/http')
local queue = {}

local function http_handler(self)
    local params = http_util.url_search_param(self.param_list, self.param_dict)
    local command = http_util.create_request(self.method, self.url..params)
        .add_custom_headers(self.header_list, self.header_dict)
        .add_body_content(self.body_content)
        .to_curl_cmd()

    local threadCode = 'local command, channel = ...\n'
        ..'local handle = io and io.popen and io.popen(command)\n'
        ..'if handle then\n'
        ..'    local stdout = handle:read(\'*a\')\n'
        ..'    local ok, stderr = handle:close()\n'
        ..'    love.thread.getChannel(channel..\'ok\'):push(ok)\n'
        ..'    love.thread.getChannel(channel..\'stdout\'):push(stdout)\n'
        ..'    love.thread.getChannel(channel..\'stderr\'):push(stderr)\n'
        ..'else\n'
        ..'    love.thread.getChannel(channel..\'ok\'):push(false)\n'
        ..'    love.thread.getChannel(channel..\'stderr\'):push(\'command failed\')\n'
        ..'end'

    self.promise()
    queue[#queue + 1] = self
    local thread = love.thread.newThread(threadCode)
    thread:start(command, tostring(self))
end

local function http_callback(self)
    local channel = tostring(self)
    local ok = love.thread.getChannel(channel..'ok'):pop()
    if ok ~= nil then
        local stdout = love.thread.getChannel(channel..'stdout'):pop() or ''
        local stderr = love.thread.getChannel(channel..'stderr'):pop() or ''
        local index = stdout:find("[^\n]*$") or 1
        local status = tonumber(stdout:sub(index))
        if not ok then
            self.std.http.ok = false
            self.std.http.error = stderr or stdout or 'unknown error!'
        else
            self.std.http.ok = http_util.is_ok(status)
            self.std.http.body = stdout:sub(1, index - 2)
            self.std.http.status = status
        end    
        self.resolve()
        return true
    end
    return false
end

local function install(std, engine)
    std.bus.listen('loop',function()
        local index = 1
        while index <= #queue do
            if http_callback(queue[index]) then
                table.remove(queue, index)
            end
            index = index + 1
        end
    end)
end

local P = {
    handler=http_handler,
    install=install
}

return P
