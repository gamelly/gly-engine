local test = require('src/lib/util/test')
local zeebo_color = require('src/lib/object/color')

local std = {}
zeebo_color.install(std)

function test_color_install()
    assert(std.color.white == 0xFFFFFFFF)
end

test.unit(_G)
