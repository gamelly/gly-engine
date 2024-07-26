local luaunit = require('luaunit')
local engine_csv = require('src/lib/engine/csv')

zeebo_csv = engine_csv.install()

function test_simple_csv()
    local result = {}
    local content = 'zig,zag,zom\nfoo,bar,z\nbip,bop,bup'
    local expected = {
        {
            zig='foo',
            zag='bar',
            zom='z'
        },
        {
            zig='bip',
            zag='bop',
            zom='bup'
        }
    }

    zeebo_csv.csv(content, result)
    luaunit.assertEquals(result, expected)
end

os.exit(luaunit.LuaUnit.run())
