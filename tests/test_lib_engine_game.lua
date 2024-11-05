local luaunit = require('luaunit')
local engine_game = require('src/lib/engine/api/game')

function test_game_reset()
    local index = 1
    local buses = {}
    local std = {
        node = {},
        bus = {
            listen = function() end,
            emit = function(key)
                buses[key] = index
                index = index + 1
            end
        }
    }

    zeebo_game = engine_game.install(std, {}, {})
    zeebo_game.reset()

    luaunit.assertEquals(buses.exit, 1)
    luaunit.assertEquals(buses.init, 2)
    luaunit.assertEquals(index, 3)
end

function test_game_exit()
    local index = 1
    local buses = {}
    local std = {
        bus = {
            listen = function() end,
            emit = function(key)
                buses[key] = index
                index = index + 1
            end
        }
    }

    zeebo_game = engine_game.install(std, {}, {})
    zeebo_game.exit()

    luaunit.assertEquals(buses.exit, 1)
    luaunit.assertEquals(buses.quit, 2)
    luaunit.assertEquals(index, 3)
end

os.exit(luaunit.LuaUnit.run())
