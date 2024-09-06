local luaunit = require('luaunit')
local lua_util = require('src/lib/util/lua')

function test_no_support_utf8()
    jit = nil
    _VERSION = 'Lua 5.1'
    luaunit.assertEquals(lua_util.has_support_utf8(), false)
end

function test_lua_jit_support_utf8()
    jit = true
    _VERSION = 'Lua 5.1'
    luaunit.assertEquals(lua_util.has_support_utf8(), true)
end

function test_lua_5_3_support_utf8()
    jit = nil
    _VERSION = 'Lua 5.3'
    luaunit.assertEquals(lua_util.has_support_utf8(), true)
end

os.exit(luaunit.LuaUnit.run())
