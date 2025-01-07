local luaunit = require('luaunit')
local zeebo_bundler = require('src/lib/cli/bundler')
local mock_io = require('mock/io')

io.open = mock_io.open({
    ['src/lib/object/application.lua'] = 'local math = require(\'math\')',
    ['src/main.lua'] = 'local os = require(\'os\')\n'
        ..'local application_default = require(\'src/lib/object/application\')\n'
        ..'local application = require(\'src/lib/object/application\')\n'
})

function test_bug_103_bundler_repeats_packages_with_different_variables()
    zeebo_bundler.build('src/main.lua', 'dist/main1.lua')
    local dist_file = io.open('dist/main1.lua', 'r')
    local dist_text = dist_file and dist_file:read('*a')
    local count = select(2, dist_text:gsub('= nil', ''))
    assert(count == 1)
    assert(dist_text:find('application_default = src_lib_object_application'))
    assert(dist_text:find('application = src_lib_object_application'))
end

os.exit(luaunit.LuaUnit.run())
