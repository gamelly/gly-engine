local test = require('src/lib/util/test')
local protocol_http = require('ee/lib/protocol/http_ginga')

local std = {bus = {listen = function() end}}

function test_bug_53_incorrect_url_ipv4()
    local protocol = protocol_http.install(std, {})
    local http_handler = protocol.handler
    local self = {
        url='http://192.168.0.1',
        promise = function () end,
        application = application
    }

    http_handler(self)
    assert(self.p_host == '192.168.0.1')
    assert(self.p_port == 80)
end

function test_bug_53_incorrect_url_ipv4_with_port()
    local protocol = protocol_http.install(std, {})
    local http_handler = protocol.handler
    local self = {
        url='http://192.168.0.2:8808',
        promise = function () end,
        application = application
    }

    http_handler(self)
    assert(self.p_host == '192.168.0.2')
    assert(self.p_port == 8808)
end

function test_bug_59_empty_content_response()
    local protocol = protocol_http.install(std, {})
    local http_handler = protocol.handler
    local self = {
        p_header_pos = 35,
        p_data = 'HTTP/1.0 204 OK\r\nConection: Close\r\n'
    }
    --[[
    application.internal.http.callbacks.http_headers(self)
    luaunit.assertEquals(self.p_content_size, 0)
    ]]
end

test.unit(_G)
