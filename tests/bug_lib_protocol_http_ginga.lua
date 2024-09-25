local luaunit = require('luaunit')
local protocol_http = require('src/lib/protocol/http_ginga')

function test_bug_53_incorrect_url_ipv4()
    local application = {}
    local protocol = protocol_http.install({}, {}, application)
    local http_handler = protocol.handler
    local self = {
        url='http://192.168.0.1',
        promise = function () end,
        application = application
    }

    http_handler(self)
    luaunit.assertEquals(self.p_host, '192.168.0.1')
    luaunit.assertEquals(self.p_port, 80)
end

function test_bug_53_incorrect_url_ipv4_with_port()
    local application = {}
    local protocol = protocol_http.install({}, {}, application)
    local http_handler = protocol.handler
    local self = {
        url='http://192.168.0.2:8808',
        promise = function () end,
        application = application
    }

    http_handler(self)
    luaunit.assertEquals(self.p_host, '192.168.0.2')
    luaunit.assertEquals(self.p_port, 8808)
end

function test_bug_59_empty_content_response()
    local application = {}
    local protocol = protocol_http.install({}, {}, application)
    local http_handler = protocol.handler
    local self = {
        p_header_pos = 35,
        p_data = 'HTTP/1.0 204 OK\r\nConection: Close\r\n'
    }
    application.internal.http.callbacks.http_headers(self)
    luaunit.assertEquals(self.p_content_size, 0)
end

os.exit(luaunit.LuaUnit.run())
