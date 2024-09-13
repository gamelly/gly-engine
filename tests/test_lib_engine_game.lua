local luaunit = require('luaunit')
local engine_game = require('src/lib/engine/game')

function test_game_reset()
    local index = 1
    local init = nil
    local exit = nil
    local application = {
        callbacks = {
            init = function()
                init = index
                index = index + 1
            end,
            exit = function()
                exit = index
                index = index + 1
            end
        }
    }

    zeebo_game = engine_game.install({application=application})
    zeebo_game.reset()

    luaunit.assertEquals(exit, 1)
    luaunit.assertEquals(init, 2)
end

function test_game_exit()
    local index = 1
    local exit = nil
    local application = {
        callbacks = {
            exit = function()
                exit = index
                index = index + 1
            end
        }
    }

    zeebo_game = engine_game.install({application=application}, application.callbacks.exit)
    zeebo_game.exit()

    luaunit.assertEquals(exit, 2)
end

os.exit(luaunit.LuaUnit.run())
