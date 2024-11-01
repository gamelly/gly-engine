local zeebo_compiler = require('src/lib/cli/compiler')
local zeebo_bundler = require('src/lib/cli/bundler')
local zeebo_package = require('src/lib/cli/package')
local zeebo_filler = require('src/lib/cli/filler')
local zeebo_fs = require('src/lib/cli/fs')

local function bundler(args)
    local path, file = args.file:match("(.-)([^/\\]+)$")
    return zeebo_bundler.build(path, file, args.dist..file)
end

local function compiler(args)
    return zeebo_compiler.build(args.file, args.dist)
end

local function love_zip(args)
    os.execute('mkdir -p '..args.dist..'_love')
    os.execute('mv '..args.path..'/* '..args.dist..'_love 2> /dev/null')
    local zip_pid = io.popen('cd '..args.dist..'_love && zip -9 -r Game.love .')
    local stdout = zip_pid:read('*a')
    local ok = zip_pid:close()    
    zeebo_fs.move(args.dist..'_love/Game.love', args.dist..'Game.love')
    zeebo_fs.clear(args.dist..'_love')
    os.remove(args.dist..'_love')
    return ok, stdout
end

local function love_exe(args)
    return false, 'not implemented!'
end

local function haxe_build(args)
    local game_name = args.game
    local game_file, file_error = io.open(game_name, 'r')
    local game_content = game_file and game_file:read('*a')

    if file_error then
        return false, file_error
    end

    local pattern_utf8 = '_G%.require%("lua%-utf8"%)'
    local replace_utf8 = 'select(2, pcall(require, "lua-utf8")) or select(2, pcall(require, "utf8")) or string'
    local pattern_object = 'std%.(%w+):(%w+)'
    local replace_object = 'std.%1.%2'

    game_content = game_content:gsub(pattern_utf8, replace_utf8)
    game_content = game_content:gsub(pattern_object, replace_object)

    game_file:close()
    game_file, file_error = io.open(game_name, 'w')

    if file_error then
        return false, file_error
    end

    game_file:write(game_content)
    game_file:close()
    
    return true
end

local function package_del(args)
    return zeebo_package.del(args.file, args.module)
end

local function template_fill(args)
    return zeebo_filler.put(args.file, tonumber(args.size))
end

local P = {
    bundler = bundler,
    compiler = compiler,
    ['tool-haxe-build'] = haxe_build,
    ['tool-love-zip'] = love_zip,
    ['tool-love-exe'] = love_exe,
    ['tool-package-del'] = package_del,
    ['tool-template-fill'] = template_fill
}

return P
