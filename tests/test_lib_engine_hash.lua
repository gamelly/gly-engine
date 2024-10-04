local luaunit = require('luaunit')
local engine_hash = require('src/lib/engine/hash')

local std = engine_hash.install(nil, nil, nil, {'awesome', function() return 42 end})

function test_fingerprint()
    local expected = std.hash.djb2('awesome42')
    local result = std.hash.fingerprint()
    luaunit.assertEquals(expected, result)
end

function test_diff_hash_foo_bar()
    local foo = std.hash.djb2('foo')
    local bar = std.hash.djb2('bar')
    luaunit.assertNotEquals(foo, bar)
end

function test_collision_stylist_subgenera()
    local stylist = std.hash.djb2('stylist')
    local subgenera = std.hash.djb2('subgenera')
    luaunit.assertEquals(stylist, subgenera)
end


os.exit(luaunit.LuaUnit.run())
