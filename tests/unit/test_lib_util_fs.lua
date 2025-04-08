local util_fs = require('src/lib/util/fs')
local test = require('src/lib/util/test')


function test_path_with_src2()
    local path = util_fs.path('foo/bar', 'extra.txt')

    assert(path.get_file() == 'extra.txt')
    assert(path.get_filename() == 'extra')
    assert(path.get_ext() == 'txt')
    assert(path.get_win_path() == 'foo\\bar\\')
    assert(path.get_unix_path() == 'foo/bar/')
end


function test_unix_foo_bar_z_txt()
    local file = util_fs.file('foo/bar/z.txt')

    assert(file.get_file() == 'z.txt')
    assert(file.get_filename() == 'z')
    assert(file.get_ext() == 'txt')
    assert(file.get_win_path() == 'foo\\bar\\')
    assert(file.get_unix_path() == 'foo/bar/')
end

function test_win_baz_bar_y_txt()
    local file = util_fs.file('baz\\bar\\y.exe')

    assert(file.get_file() == 'y.exe')
    assert(file.get_filename() == 'y')
    assert(file.get_ext() == 'exe')
    assert(file.get_win_path() == 'baz\\bar\\')
    assert(file.get_unix_path() == 'baz/bar/')
end


function test_unix_absolute()
    local file = util_fs.file('/etc/hosts')
	
    assert(file.get_file() == 'hosts')
    assert(file.get_filename() == 'hosts')
    assert(file.get_ext() == '')
    assert(file.get_unix_path() == '/etc/')
    assert(file.get_win_path() == 'C:\\etc\\')
end


function test_win_absolute()
    local file = util_fs.file('\\Windows\\System32\\drivers\\etc\\hosts')

    assert(file.get_file() == 'hosts')
    assert(file.get_filename() == 'hosts')
    assert(file.get_ext() == '')
    assert(file.get_win_path() == 'C:\\Windows\\System32\\drivers\\etc\\')
    assert(file.get_unix_path() == '/Windows/System32/drivers/etc/')
end

function test_win_absolute_with_driver()
    local file = util_fs.file('D:\\Windows\\System32\\drivers\\etc\\hosts')

    assert(file.get_file() == 'hosts')
    assert(file.get_filename() == 'hosts')
    assert(file.get_ext() == '')
    assert(file.get_win_path() == 'D:\\Windows\\System32\\drivers\\etc\\')
    assert(file.get_unix_path() == '/Windows/System32/drivers/etc/')
end

function test_unix_path()
    local file = util_fs.path('/etc/bin')

    assert(file.get_file() == '')
    assert(file.get_filename() == '')
    assert(file.get_ext() == '')
    assert(file.get_win_path() == 'C:\\etc\\bin\\')
    assert(file.get_unix_path() == '/etc/bin/')
end

function test_win_path()
    local file = util_fs.path('C:/win32/program files')

    assert(file.get_file() == '')
    assert(file.get_filename() == '')
    assert(file.get_ext() == '')
    assert(file.get_win_path() == 'C:\\win32\\program files\\')
    assert(file.get_unix_path() == '/win32/program files/')
end

function test_detect_separator()
    mock_separator = '\\'
    local file_win = util_fs.path('/user')
    mock_separator = '/'
    local file_unix = util_fs.path('/home')

    assert(file_win.get_fullfilepath() == 'C:\\user\\')
    assert(file_unix.get_fullfilepath() == '/home/')

end

function test_empty_protect()
    assert(util_fs.file(nil) == nil)
    assert(util_fs.file('') == nil)
    assert(util_fs.file(' ') == nil)
    assert(util_fs.file('\n') == nil)
end

test.unit(_G)
