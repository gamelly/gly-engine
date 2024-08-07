local luaunit = require('luaunit')
local mock_io = require('mock/io')
local protocol_http = require('src/lib/protocol/http_curl')

local mock_popen = mock_io.open({
    ['curl -L --silent --insecure -w "\n%{http_code}" -X GET pudim.com.br'] = {
        read=function () return 'i love pudim!\n200' end,
        close=function () return true, nil end
    },
    ['curl -L --silent --insecure -w "\n%{http_code}" -X POST -H "Authorization: bearer secret" pudim.com.br'] = {
        read=function () return 'method not allowed!\n403' end,
        close=function () return true, nil end
    },
    ['curl -L --silent --insecure -w "\n%{http_code}" -X POST pudim.com.brz&z=zoom'] = {
        read=function () return 'me too!\n201' end,
        close=function () return true, nil end
    },
    ['curl -L --silent --insecure -w "\n%{http_code}" --HEAD '] = {
        read=function () return '' end,
        close=function () return false, 'no URL specified!' end
    },
})

function test_http_get_200()
    local std = {http={}}
    io.popen = mock_popen
    
    protocol_http.handler({
        std = std,
        url = 'pudim.com.br',
        method = 'GET'
    })

    luaunit.assertEquals(std.http.ok, true)
    luaunit.assertEquals(std.http.error, nil)
    luaunit.assertEquals(std.http.status, 200)
    luaunit.assertEquals(std.http.body, 'i love pudim!\n')
end

function test_http_post_201()
    local std = {http={}}
    io.popen = mock_popen
    
    protocol_http.handler({
        std = std,
        param_list = {'foo', 'bar', 'z'},
        param_dict = {
            ['foo'] = 'zig',
            ['bar'] = 'zag',
            ['z'] = 'zoom'
        },
        url = 'pudim.com.br',
        method = 'POST'
    })

    luaunit.assertEquals(std.http.ok, true)
    luaunit.assertEquals(std.http.error, nil)
    luaunit.assertEquals(std.http.status, 201)
    luaunit.assertEquals(std.http.body, 'me too!\n')
end

function test_http_post_403()
    local std = {http={}}
    io.popen = mock_popen
    
    protocol_http.handler({
        std = std,
        header_list = {'Authorization'},
        header_dict = {['Authorization'] = 'bearer secret'},
        url = 'pudim.com.br',
        method = 'POST'
    })

    luaunit.assertEquals(std.http.ok, false)
    luaunit.assertEquals(std.http.error, nil)
    luaunit.assertEquals(std.http.status, 403)
    luaunit.assertEquals(std.http.body, 'method not allowed!\n')
end

function test_http_head_error()
    local std = {http={}}
    io.popen = mock_popen
    
    protocol_http.handler({
        std = std,
        url = '',
        method = 'HEAD'
    })

    luaunit.assertEquals(std.http.ok, false)
    luaunit.assertEquals(std.http.error, 'no URL specified!')
    luaunit.assertEquals(std.http.status, nil)
    luaunit.assertEquals(std.http.body, nil)
end

function test_http_popen_error()
    local std = {http={}}
    io.popen = nil
    
    protocol_http.handler({
        std = std,
        url = 'pudim.com.br',
        method = 'GET'
    })

    luaunit.assertEquals(std.http.ok, false)
    luaunit.assertEquals(std.http.error, 'failed to spawn process!')
    luaunit.assertEquals(std.http.status, nil)
    luaunit.assertEquals(std.http.body, nil)
end

os.exit(luaunit.LuaUnit.run())
