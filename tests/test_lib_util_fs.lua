local luaunit = require('luaunit')
local util_fs = require('src/lib/util/fs')

function test_path_with_src2()
    local path = util_fs.path('foo/bar', 'extra.txt')
    luaunit.assertEquals(path.get_file(), 'extra.txt')
    luaunit.assertEquals(path.get_filename(), 'extra')
    luaunit.assertEquals(path.get_ext(), 'txt')
    luaunit.assertEquals(path.get_win_path(), '.\\foo\\bar\\')
    luaunit.assertEquals(path.get_unix_path(), './foo/bar/')
end

function test_unix_foo_bar_z_txt()
    local file = util_fs.file('foo/bar/z.txt')
    luaunit.assertEquals(file.get_file(), 'z.txt')
    luaunit.assertEquals(file.get_filename(), 'z')
    luaunit.assertEquals(file.get_ext(), 'txt')
    luaunit.assertEquals(file.get_win_path(), '.\\foo\\bar\\')
    luaunit.assertEquals(file.get_unix_path(), './foo/bar/')
end

function test_win_baz_bar_y_txt()
    local file = util_fs.file('baz\\bar\\y.exe')
    luaunit.assertEquals(file.get_file(), 'y.exe')
    luaunit.assertEquals(file.get_filename(), 'y')
    luaunit.assertEquals(file.get_ext(), 'exe')
    luaunit.assertEquals(file.get_win_path(), '.\\baz\\bar\\')
    luaunit.assertEquals(file.get_unix_path(), './baz/bar/')
end

function test_unix_absolute()
    local file = util_fs.file('/etc/hosts')
    luaunit.assertEquals(file.get_file(), 'hosts')
    luaunit.assertEquals(file.get_filename(), 'hosts')
    luaunit.assertEquals(file.get_ext(), '')
    luaunit.assertEquals(file.get_unix_path(), '/etc/')
    luaunit.assertEquals(file.get_win_path(), 'C:\\etc\\')
end

function test_win_absolute()
    local file = util_fs.file('\\Windows\\System32\\drivers\\etc\\hosts')
    luaunit.assertEquals(file.get_file(), 'hosts')
    luaunit.assertEquals(file.get_filename(), 'hosts')
    luaunit.assertEquals(file.get_ext(), '')
    luaunit.assertEquals(file.get_win_path(), 'C:\\Windows\\System32\\drivers\\etc\\')
    luaunit.assertEquals(file.get_unix_path(), '/Windows/System32/drivers/etc/')
end

function test_win_absolute_with_driver()
    local file = util_fs.file('D:\\Windows\\System32\\drivers\\etc\\hosts')
    luaunit.assertEquals(file.get_file(), 'hosts')
    luaunit.assertEquals(file.get_filename(), 'hosts')
    luaunit.assertEquals(file.get_ext(), '')
    luaunit.assertEquals(file.get_win_path(), 'D:\\Windows\\System32\\drivers\\etc\\')
    luaunit.assertEquals(file.get_unix_path(), '/Windows/System32/drivers/etc/')
end

function test_unix_path()
    local file = util_fs.path('/etc/bin')
    luaunit.assertEquals(file.get_file(), '')
    luaunit.assertEquals(file.get_filename(), '')
    luaunit.assertEquals(file.get_ext(), '')
    luaunit.assertEquals(file.get_win_path(), 'C:\\etc\\bin\\')
    luaunit.assertEquals(file.get_unix_path(), '/etc/bin/')
end

function test_win_path()
    local file = util_fs.path('C:/win32/program files')
    luaunit.assertEquals(file.get_file(), '')
    luaunit.assertEquals(file.get_filename(), '')
    luaunit.assertEquals(file.get_ext(), '')
    luaunit.assertEquals(file.get_win_path(), 'C:\\win32\\program files\\')
    luaunit.assertEquals(file.get_unix_path(), '/win32/program files/')
end

function test_detect_separator()
    mock_separator = '\\'
    local file_win = util_fs.path('/user')
    mock_separator = '/'
    local file_unix = util_fs.path('/home')
    luaunit.assertEquals(file_win.get_fullfilepath(), 'C:\\user\\')
    luaunit.assertEquals(file_unix.get_fullfilepath(), '/home/')
end

function test_empty_protect()
    luaunit.assertEquals(util_fs.file(nil), nil)
    luaunit.assertEquals(util_fs.file(''), nil)
    luaunit.assertEquals(util_fs.file(' '), nil)
    luaunit.assertEquals(util_fs.file('\n'), nil)
end

os.exit(luaunit.LuaUnit.run())
