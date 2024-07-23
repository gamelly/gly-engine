local luaunit = require('luaunit')
local mock_io = require('mock/io')
local protocol_http = require('src/lib/protocol/http_curl')

io.popen = mock_io.open({
    ['curl -L --silent --insecure -w "\n%{http_code}" -X GET pudim.com.br'] = {
        read=function () return 'i love pudim!\n200' end,
        close=function () return true, nil end
    },
    ['curl -L --silent --insecure -w "\n%{http_code}" -X POST pudim.com.br'] = {
        read=function () return 'method not allowed!\n403' end,
        close=function () return true, nil end
    },
    ['curl -L --silent --insecure -w "\n%{http_code}" --HEAD '] = {
        read=function () return '' end,
        close=function () return false, 'no URL specified!' end
    },
})

function test_http_get_200()
    local ok, status, body, h = false, 0, nil, nil
    
    protocol_http.handler({
        std = {http={}},
        url = 'pudim.com.br',
        method = 'GET',
        success_handler = function(std) ok, status, body, h = std.http.ok, std.http.status, std.http.body, 1 end,
        failed_handler = function(std) ok, status, body, h = std.http.ok, std.http.status, std.http.body, 2 end,
        error_handler = function(std) ok, status, body, h = std.http.ok, std.http.status, std.http.error, 3 end
    })

    luaunit.assertEquals(h, 1)
    luaunit.assertEquals(ok, true)
    luaunit.assertEquals(status, 200)
    luaunit.assertEquals(body, 'i love pudim!\n')
end

function test_http_post_403()
    local ok, status, body, h = false, 0, nil, nil
    
    protocol_http.handler({
        std = {http={}},
        url = 'pudim.com.br',
        method = 'POST',
        success_handler = function(std) ok, status, body, h = std.http.ok, std.http.status, std.http.body, 1 end,
        failed_handler = function(std) ok, status, body, h = std.http.ok, std.http.status, std.http.body, 2 end,
        error_handler = function(std) ok, status, body, h = std.http.ok, std.http.status, std.http.error, 3 end
    })

    luaunit.assertEquals(h, 2)
    luaunit.assertEquals(ok, false)
    luaunit.assertEquals(status, 403)
    luaunit.assertEquals(body, 'method not allowed!\n')
end

function test_http_head_error()
    local ok, status, body, h = false, 0, nil, nil
    
    protocol_http.handler({
        std = {http={}},
        url = '',
        method = 'HEAD',
        success_handler = function(std) ok, status, body, h = std.http.ok, std.http.status, std.http.body, 1 end,
        failed_handler = function(std) ok, status, body, h = std.http.ok, std.http.status, std.http.body, 2 end,
        error_handler = function(std) ok, status, body, h = std.http.ok, std.http.status, std.http.error, 3 end
    })

    luaunit.assertEquals(h, 3)
    luaunit.assertEquals(ok, false)
    luaunit.assertEquals(status, nil)
    luaunit.assertEquals(body, 'no URL specified!')
end

os.exit(luaunit.LuaUnit.run())
