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

function test_shared_args_param_basic()
    local args = {'value1', '--flag', 'param1', '--flag2', 'param2', 'value2'}
    local args_get = {'flag', 'flag2'}
    luaunit.assertEquals(zeebo_args.param(args, args_get, 1, 'default'), 'value1')
    luaunit.assertEquals(zeebo_args.param(args, args_get, 2, 'default'), 'value2')
end

function test_shared_args_param_position_out_of_range()
    local args = {'value1', '--flag', 'param1'}
    local args_get = {'flag'}
    luaunit.assertEquals(zeebo_args.param(args, args_get, 2, 'default'), 'default')
end

function test_shared_args_param_no_arguments()
    local args = {}
    local args_get = {'flag'}
    luaunit.assertEquals(zeebo_args.param(args, args_get, 1, 'default'), 'default')
end

function test_shared_args_param_single_argument()
    local args = {'value1'}
    local args_get = {}
    luaunit.assertEquals(zeebo_args.param(args, args_get, 1, 'default'), 'value1')
end

os.exit(luaunit.LuaUnit.run())
