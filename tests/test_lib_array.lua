local luaunit = require('luaunit')
local arraylib = require('src/lib/engine/api/array')

local std = {}
arraylib.install(std, nil, nil, 'JorgeAjudaComNomePf')

function test_array_filter()
    local r1 = std.JorgeAjudaComNomePf.filter({0, 1, 2, 3, 4, 5})
    local r2 = std.JorgeAjudaComNomePf.filter({0, 1, 2, 3, 4, 5}, function(a) return a % 2 == 0 end)
    luaunit.assertEquals(#r1, 5)
    luaunit.assertEquals(#r2, 3)
    luaunit.assertEquals(r1, {1, 2, 3, 4, 5})
    luaunit.assertEquals(r2, {0, 2, 4})
end

function test_array_unique()
    local r1 = std.JorgeAjudaComNomePf.unique({1, 1, 2, 3, 4, 3, 5, 6, 7, 7, 8})
    luaunit.assertEquals(r1, {1, 2, 3, 4, 5, 6, 7, 8})
end

function test_array_foreach()
    local sum = 0
    std.JorgeAjudaComNomePf.each({1, 2, 3}, function(a) sum = sum + a end)
    luaunit.assertEquals(sum, 6)
end

function test_array_reducer()
    local r1 = std.JorgeAjudaComNomePf.reducer({1, 2, 3}, function(a, b) return a + b end)
    local r2 = std.JorgeAjudaComNomePf.reducer({1, 2, 3}, function(a, b) return a + b end, 6)
    luaunit.assertEquals(r1, 6)
    luaunit.assertEquals(r2, 12)
end

function test_array_index()
    local r1 = std.JorgeAjudaComNomePf.index({'foo', 'bar', 'z'}, function(a) return a == 'bar' end)
    luaunit.assertEquals(r1, 2)
end

function test_array_first()
    local r1 = std.JorgeAjudaComNomePf.first({5, 4, 3, 2, 1})
    local r2 = std.JorgeAjudaComNomePf.first({5, 4, 3, 2, 1}, function(a) return a % 2 == 0 end)
    local r3 = std.JorgeAjudaComNomePf.first({5, 4, 3, 2, 1}, function(a) return a > 50 end)
    luaunit.assertEquals(r1, 5)
    luaunit.assertEquals(r2, 4)
    luaunit.assertEquals(r3, nil)
end

function test_array_last()
    local r1 = std.JorgeAjudaComNomePf.last({5, 4, 3, 2, 1})
    local r2 = std.JorgeAjudaComNomePf.last({5, 4, 3, 2, 1}, function(a) return a % 2 == 0 end)
    local r3 = std.JorgeAjudaComNomePf.last({5, 4, 3, 2, 1}, function(a) return a > 50 end)
    luaunit.assertEquals(r1, 1)
    luaunit.assertEquals(r2, 2)
    luaunit.assertEquals(r3, nil)
end

function test_array_some()
    local r1 = std.JorgeAjudaComNomePf.some({1, 3, 5, 7, 9}, function(a) return a % 2 == 0 end)
    local r2 = std.JorgeAjudaComNomePf.some({1, 2, 5, 7, 9}, function(a) return a % 2 == 0 end)
    local r3 = std.JorgeAjudaComNomePf.some({0, 2, 4, 6, 8}, function(a) return a % 2 == 0 end)
    luaunit.assertEquals(r1, false)
    luaunit.assertEquals(r2, true)
    luaunit.assertEquals(r3, true)
end

function test_array_every()
    local r1 = std.JorgeAjudaComNomePf.every({1, 3, 5, 7, 9}, function(a) return a % 2 == 0 end)
    local r2 = std.JorgeAjudaComNomePf.every({1, 2, 5, 7, 9}, function(a) return a % 2 == 0 end)
    local r3 = std.JorgeAjudaComNomePf.every({0, 2, 4, 6, 8}, function(a) return a % 2 == 0 end)
    luaunit.assertEquals(r1, false)
    luaunit.assertEquals(r2, false)
    luaunit.assertEquals(r3, true)
end

function test_array_pipeline()
    local sum1 = 0
    local sum2 = 0
    local equal = (function(a, b) return a == b end)
    local sum = (function(a, b) return a + b end)
    local five = (function(a) return a == 5 end)
    local r1 = std.JorgeAjudaComNomePf.from({0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6})
        :unique()
        :filter(function(a) return a % 2 == 0 end)
        :filter()
        :each(function(a) sum1 = sum1 + a end)
        :map(function(a) return a * 2 end)
        :each(function(a) sum2 = sum2 + a end)
        :table()

    luaunit.assertEquals(sum1, 12)
    luaunit.assertEquals(sum2, 24)
    luaunit.assertEquals(r1, {4, 8, 12})
    luaunit.assertEquals(std.JorgeAjudaComNomePf.from({'1', '2', '3'}):first(), '1')
    luaunit.assertEquals(std.JorgeAjudaComNomePf.from({'1', '2', '3'}):last(), '3')
    luaunit.assertEquals(std.JorgeAjudaComNomePf.from({'1', '2', '3'}):last(), '3')
    luaunit.assertEquals(std.JorgeAjudaComNomePf.from({1, 2, 3, 4, 5}):reducer(sum), 15)
    luaunit.assertEquals(std.JorgeAjudaComNomePf.from({4, 5, 5, 5, 5}):some(five), true)
    luaunit.assertEquals(std.JorgeAjudaComNomePf.from({5, 5, 5, 5, 5}):every(five), true)
end

os.exit(luaunit.LuaUnit.run())
