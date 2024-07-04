local luaunit = require('luaunit')
local zeebo_args = require('src/shared/args')

function test_shared_args_get_basic()
    local args = {'--option', 'value'}
    luaunit.assertEquals(zeebo_args.get(args, 'option', 'default'), 'value')
end

function test_shared_args_get_default_value()
    local args = {'--other', 'value'}
    luaunit.assertEquals(zeebo_args.get(args, 'option', 'default'), 'default')
end

function test_shared_args_get_missing_argument()
    local args = {'--option'}
    luaunit.assertEquals(zeebo_args.get(args, 'option', 'default'), 'default')
end

function test_shared_args_get_no_arguments()
    local args = {}
    luaunit.assertEquals(zeebo_args.get(args, 'option', 'default'), 'default')
end

function test_shared_args_has_true()
    local args = {'--option'}
    luaunit.assertTrue(zeebo_args.has(args, 'option'))
end

function test_shared_args_has_false()
    local args = {'--other'}
    luaunit.assertFalse(zeebo_args.has(args, 'option'))
end

function test_shared_args_has_no_arguments()
    local args = {}
    luaunit.assertFalse(zeebo_args.has(args, 'option'))
end

os.exit(luaunit.LuaUnit.run())
