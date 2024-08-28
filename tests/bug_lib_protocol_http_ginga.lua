local luaunit = require('luaunit')
local protocol_http = require('src/lib/protocol/http_ginga')

function test_bug_59_empty_content_response()
    local application = {}
    local self = {
        p_header_pos = 35,
        p_data = 'HTTP/1.0 204 OK\r\nConection: Close\r\n'
    }
    local http_handler = protocol_http.install({}, {}, application)
    application.internal.http.callbacks.http_headers(self)
    luaunit.assertEquals(self.p_content_size, 0)
end

os.exit(luaunit.LuaUnit.run())
