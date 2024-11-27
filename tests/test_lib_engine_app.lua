local luaunit = require('luaunit')
local engine_game = require('src/lib/engine/api/app')


function test_app_reset()
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
    
    local config = {
        quit = function()
            print("Config quit foi chamado!")
        end
    }

    zeebo_game = engine_game.install(std, {}, {})
    zeebo_game.reset()

    luaunit.assertEquals(buses.exit, 1)
    luaunit.assertEquals(buses.init, 2)
    luaunit.assertEquals(index, 3)
    std.bus:emit('post_quit')
end

function test_app_reset_no_node()
    local exit_called = false
    local init_called = false

    local std = {
        bus = {
            listen = function() end,
            emit = function() end
        }
    }


    local engine = {
        root = {
            data = {},
            callbacks = {}
        }
    }

    engine.root.callbacks.exit = function(std_param, data_param)
        luaunit.assertEquals(std_param, std)
        luaunit.assertEquals(data_param, engine.root.data)
        exit_called = true
    end

    engine.root.callbacks.init = function(std_param, data_param)
        luaunit.assertEquals(std_param, std)
        luaunit.assertEquals(data_param, engine.root.data)
        init_called = true
    end
    zeebo_game = engine_game.install(std, engine, {})
    zeebo_game.reset()

    luaunit.assertTrue(exit_called)
    luaunit.assertTrue(init_called)
end

function test_app_exit()
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

function test_app_title()

    local function mock_set_title(window_name)
        luaunit.assertEquals(window_name, "Teste")
    end

    local std = {
        bus = {
            listen = function() end,
            emit = function() end
        },
        app ={
            title = nil
        }
    }
    local config = {
        set_title = mock_set_title
    }

    local zeebo_game = engine_game.install(std, {}, config)

    zeebo_game.title("Teste")

end

function test_app_install()
    local exit_called = false
    local init_called = false
    local quit_called = false

    local std = {
        bus = {
            listen = function(event, callback)
                if event == 'post_quit' then
                    callback()  
                end
            end,
            emit = function() end
        }
    }

    local engine = {
        root = {
            data = {},
            callbacks = {}
        }
    }

    engine.root.callbacks.exit = function(std_param, data_param)
        luaunit.assertEquals(std_param, std)
        luaunit.assertEquals(data_param, engine.root.data)
        exit_called = true
    end

    engine.root.callbacks.init = function(std_param, data_param)
        luaunit.assertEquals(std_param, std)
        luaunit.assertEquals(data_param, engine.root.data)
        init_called = true
    end

    local config = {
        set_title = function(window_name)
            luaunit.assertEquals(window_name, "Test Window")
        end,
        fps = 60,
        quit = function()
            quit_called = true  
        end
    }

    local zeebo_game = engine_game.install(std, engine, config)

    luaunit.assertNotNil(zeebo_game.title)
    luaunit.assertNotNil(zeebo_game.exit)
    luaunit.assertNotNil(zeebo_game.reset)
    luaunit.assertEquals(zeebo_game.get_fps, 60)

    zeebo_game.title("Test Window")

    zeebo_game.reset()

    luaunit.assertTrue(exit_called)
    luaunit.assertTrue(init_called)
    luaunit.assertTrue(quit_called)
end
os.exit(luaunit.LuaUnit.run())
