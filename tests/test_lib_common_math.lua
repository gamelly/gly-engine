local luaunit = require('luaunit')
local engine_math = require('src/lib/engine/api/math')
local zeebo_math = engine_math.install()

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


function test_install()
    local std ={}
    local math_lib = engine_math.install(std)
    luaunit.assertIsFunction(math_lib.clamp)
end


function test_install_math_clib()
    local math_clib = engine_math.clib.install()
    luaunit.assertIsFunction(math_clib.pow)
end

function test_install_math_clib_random()
    local math_clib = engine_math.clib_random.install()
    luaunit.assertIsFunction(math_clib.random)

    local result = math_clib.random(1, 10)
    luaunit.assertTrue(result >= 1 and result <= 10)

    -- local result2 = math_clib.random(5)
    -- luaunit.assertTrue(result >= 1 and result <= 5)

    -- local result3 = math_clib.random()
    -- luaunit.assertTrue(result >= 1)

    -- local result4 = math_clib.random(nil, nil)
    -- luaunit.assertTrue(result >= 1)
end

os.exit(luaunit.LuaUnit.run())
