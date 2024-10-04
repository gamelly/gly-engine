local zeebo_compiler = require('src/lib/cli/compiler')
local zeebo_bundler = require('src/lib/cli/bundler')

local function bundler(args)
    local path, file = args.file:match("(.-)([^/\\]+)$")
    return zeebo_bundler.build(path, file, args.dist..file)
end

local function compiler(args)
    return zeebo_compiler.build(args.file, args.dist)
end

local function love_zip(args)
    return false, 'not implemented!'
end

local function love_exe(args)
    return false, 'not implemented!'
end

local function haxe_build(args)
    local game_name = args.game
    local game_file = io.open(game_name, 'r')
    local game_content = game_file and game_file:read('*a')

    if not game_content then
        return false, 'game not found!'
    end

    local pattern_utf8 = '_G%.require%("lua%-utf8"%)'
    local replace_utf8 = 'select(2, pcall(require, "lua-utf8")) or select(2, pcall(require, "utf8")) or string'
    local pattern_object = 'std%.(%w+):(%w+)'
    local replace_object = 'std.%1.%2'

    game_content = game_content:gsub(pattern_utf8, replace_utf8)
    game_content = game_content:gsub(pattern_object, replace_object)

    game_file = io.open(game_name, 'w')

    if not game_file then
        return false, 'strange error'
    end

    game_file:write(game_content)
    
    return true
end


local P = {
    bundler = bundler,
    compiler = compiler,
    ['tool-haxe-build'] = haxe_build,
    ['tool-love-zip'] = love_zip,
    ['tool-love-exe'] = love_exe
}

return P
