local luaunit = require('luaunit')
local zeebo_color = require('src/lib/object/color')

zeebo_color = zeebo_color.install()

function test_color_install()
    luaunit.assertEquals(zeebo_color.white, 0xFFFFFFFF)
end

os.exit(luaunit.LuaUnit.run())
