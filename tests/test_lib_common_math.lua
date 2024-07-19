local luaunit = require('luaunit')
local zeebo_math = require('src/lib/common/math')

function test_clamp()
    luaunit.assertEquals(zeebo_math.clamp(10, 1, 5), 5)
    luaunit.assertEquals(zeebo_math.clamp(-10, -5, 5), -5)
    luaunit.assertEquals(zeebo_math.clamp(3, 1, 5), 3)
end

function test_dir()
    luaunit.assertEquals(zeebo_math.dir(2, 1), 1)
    luaunit.assertEquals(zeebo_math.dir(-2, 1), -1)
    luaunit.assertEquals(zeebo_math.dir(0, 1), 0)
end

function test_dis()
    luaunit.assertEquals(zeebo_math.dis(0, 0, 3, 4), 5)
end

function test_dis2()
    luaunit.assertEquals(zeebo_math.dis2(0, 0, 3, 4), 25)
end

function test_abs()
    luaunit.assertEquals(zeebo_math.abs(-5), 5)
    luaunit.assertEquals(zeebo_math.abs(10), 10)
end

function test_saw()
    luaunit.assertAlmostEquals(zeebo_math.saw(0.1), 0.4, 1e-6)
    luaunit.assertAlmostEquals(zeebo_math.saw(0.4), 0.4, 1e-6)
    luaunit.assertAlmostEquals(zeebo_math.saw(0.6), -0.4, 1e-6)
    luaunit.assertAlmostEquals(zeebo_math.saw(0.9), -0.4, 1e-6)
end

function test_lerp()
    luaunit.assertEquals(zeebo_math.lerp(0, 10, 0.5), 5)
    luaunit.assertEquals(zeebo_math.lerp(1, 5, 0.25), 2)
end

function test_map()
    luaunit.assertEquals(zeebo_math.map(5, 0, 10, 0, 100), 50)
    luaunit.assertEquals(zeebo_math.map(2, 0, 5, 0, 50), 20)
end

function test_clamp2()
    luaunit.assertEquals(zeebo_math.clamp2(10, 1, 5), 5)
    luaunit.assertEquals(zeebo_math.clamp2(-10, -5, 5), 1)
    luaunit.assertEquals(zeebo_math.clamp2(10, -5, 5), -1)
    luaunit.assertEquals(zeebo_math.clamp2(3, 1, 5), 3)
end

function test_cycle()
    luaunit.assertEquals(zeebo_math.cycle(5, 10), 0.5)
    luaunit.assertEquals(zeebo_math.cycle(15, 10), 0.5)
end

function test_min()
    luaunit.assertEquals(zeebo_math.min(1, 2, 3, 4, 5), 1)
    luaunit.assertEquals(zeebo_math.min(10, -5, 3, 0), -5)
    luaunit.assertEquals(zeebo_math.min(-1, -2, -3), -3)
    luaunit.assertEquals(zeebo_math.min({1, 2, 3, 4, 5}), 1)
end

function test_max()
    luaunit.assertEquals(zeebo_math.max(1, 2, 3, 4, 5), 5)
    luaunit.assertEquals(zeebo_math.max(10, -5, 3, 0), 10)
    luaunit.assertEquals(zeebo_math.max(-1, -2, -3), -1)
    luaunit.assertEquals(zeebo_math.max({1, 2, 3, 4, 5}), 5)
end

os.exit(luaunit.LuaUnit.run())
