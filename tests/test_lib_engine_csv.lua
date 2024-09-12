local luaunit = require('luaunit')
local encoder = require('src/lib/engine/encoder')
local csv = require('src/third_party/csv/rodrigodornelles')

local std = encoder.install(nil, nil, nil, csv, 'csv')

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

    std.csv.decode(content, result)
    luaunit.assertEquals(result, expected)
end

os.exit(luaunit.LuaUnit.run())
