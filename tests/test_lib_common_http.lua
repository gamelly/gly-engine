local luaunit = require('luaunit')
local zeebo_http = require('src/lib/engine/http')
local mock_http = require('mock/protocol_http')

local std = {}

local http_handler = mock_http.requests({
    ['example.com/status200'] = {
        ok = true,
        status = 200
    },
    ['example.com/set-status-body-param1-param2'] = {
        ok = true,
        status = function(http_object)
            return http_object.param_value_list[1]
        end,
        body = function(http_object)
            return http_object.param_value_list[2]
        end
    },
    ['example.com/set-body-lower-with-body'] = {
        ok = true,
        status = 201,
        body = function(http_object)
            return string.lower(http_object.body_content)
        end
    }
})

zeebo_http.install(std, nil, nil, http_handler)

function test_http_head_200()
    local status = 0
    local ok = nil

    std.http.head('example.com/status200')
        :success(function (std) ok, status = true, std.http.status end)
        :failed(function (std) ok, status = false, std.http.status end)
        :error(function() ok, status = false, -1 end)
        :run()

    luaunit.assertEquals(ok, true)
    luaunit.assertEquals(status, 200)
end

function test_http_head_404()
    local status = 0
    local ok = nil

    std.http.head('example.com/status404')
        :success(function (std) ok, status = true, std.http.status end)
        :failed(function (std) ok, status = false, std.http.status end)
        :error(function() ok, status = false, -1 end)
        :run()

    luaunit.assertEquals(ok, false)
    luaunit.assertEquals(status, 404)
end

function test_http_head_error()
    local message = nil
    local status = 0
    local ok = nil

    std.http.head()
        :success(function (std) ok, status = true, std.http.status end)
        :failed(function (std) ok, status = false, std.http.status end)
        :error(function() ok, status, message = false, -1, std.http.error end)
        :run()

    luaunit.assertEquals(ok, false)
    luaunit.assertEquals(status, -1)
    luaunit.assertEquals(message, 'URL not set')
end

function test_http_get_201()
    local status = 0
    local body = ''

    std.http.head('example.com/set-status-body-param1-param2')
        :param('param1', 201)
        :param('param2', 'foobarz')
        :success(function (std)
            status = std.http.status
            body = std.http.body
        end)
        :failed(function (std)
            status = std.http.status
            body = std.http.body
        end)
        :error(function() status = -1 end)
        :run()

    luaunit.assertEquals(status, 201)
    luaunit.assertEquals(body, 'foobarz')
end

function test_http_post_body()
    local ok, sttus, body = false, 0, nil

    std.http.post('example.com/set-body-lower-with-body')
        :body('FOOBARZ')
        :success(function (std) ok, status, body = std.http.ok, std.http.status, std.http.body end)
        :failed(function (std) ok, status = std.http.ok, std.http.status end)
        :error(function() ok, status = false, -1 end)
        :run()


    luaunit.assertEquals(ok, true)
    luaunit.assertEquals(status, 201)
    luaunit.assertEquals(body, 'foobarz')
end

os.exit(luaunit.LuaUnit.run())
