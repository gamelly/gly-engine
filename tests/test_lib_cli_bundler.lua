local luaunit = require('luaunit')
local zeebo_bundler = require('src/lib/cli/bundler')
local mock_io = require('mock/io')

io.open = mock_io.open({
    ['src/lib_common_math.lua'] = 'local function sum(a, b)\n'
        ..' return a + b\n'
        ..'end\n'
        ..'local P = {\n'
        ..' sum = sum\n'
        ..'}\n'
        ..'return P\n',
    ['src/main.lua'] = 'local os = require(\'os\')\n'
        ..'local zeebo_math = require(\'lib_common_math\')\n'
        ..'return zeebo_math.sum(1, 2)\n'
})

function test_simple_bundler()
    zeebo_bundler.build('src/', 'main.lua', 'dist/main1.lua')
    local dist_file = io.open('dist/main1.lua', 'r')
    local dist_text = dist_file and dist_file:read('*a')
    local dist_func = loadstring and loadstring(dist_text) or load(dist_text)
    luaunit.assertEquals(dist_func(), 3)
end

os.exit(luaunit.LuaUnit.run())
