local luaunit = require('luaunit')
local protocol_http = require('src/lib/protocol/http_ginga')

local std = {}
local game = {}
local application = {
    internal = {
        event_loop = {},
        fixed_loop = {}
    }
}
event = {
    register = function() end,
    post = function() end
}

http_handler = protocol_http.install(std, game, application)

function test_event_http_headers()
    local http = {
        header_pos = 35,
        data='HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK\r\n\r\n'
    }
    
    application.internal.http.callbacks.http_headers(nil, nil, http)

    luaunit.assertEquals(http.status, 200)
    luaunit.assertEquals(http.content_size, 2)
end

function test_event_redirect_https_error()
    local http_object = {}
    local http = {
        header='HTTP/1.1 300 Redirect\r\nLocation: https://pudim.com.br'
    }

    http_object.resolve = function() end
    http_object.set = function (key, value) http_object[key] = value end
    application.internal.http.callbacks.http_redirect(http_object, nil, http)
    

    luaunit.assertEquals(http_object.ok, false)
    luaunit.assertEquals(http_object.error, 'HTTPS is not supported!')
end

function test_event_loop_error()
    local raise_error = false
    local app = {
        internal = {
            event_loop = {},
        }
    }
    local evt = {
        class = 'tcp',
        error = 'error'
    }

    protocol_http.install(nil, nil, app)
    app.internal.http.callbacks.http_error = function () raise_error = true end
    app.internal.event_loop[1](evt)

    luaunit.assertEquals(raise_error, true)
end

os.exit(luaunit.LuaUnit.run())
