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

local P = {
    bundler = bundler,
    compiler = compiler,
    ['tool-love-zip'] = love_zip,
    ['tool-love-exe'] = love_exe
}

return P
