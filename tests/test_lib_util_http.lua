local luaunit = require('luaunit')
local zeebo_util_http = require('src/lib/util/http')

function test_no_params()
    local query = zeebo_util_http.url_search_param({}, {})
    luaunit.assertEquals(query, '')
end

function test_one_param()
    local query = zeebo_util_http.url_search_param({'foo'}, {foo='bar'})
    luaunit.assertEquals(query, '?foo=bar')
end

function test_three_params()
    local query = zeebo_util_http.url_search_param({'foo', 'z'}, {foo='bar', z='zoom'})
    luaunit.assertEquals(query, '?foo=bar&z=zoom')
end

function test_four_params_with_null()
    local query = zeebo_util_http.url_search_param({'foo', 'z', 'zig'}, {foo='bar', z='zoom'})
    luaunit.assertEquals(query, '?foo=bar&z=zoom&zig=')
end

os.exit(luaunit.LuaUnit.run())
