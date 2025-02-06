local zeebo_bundler = require('src/lib/cli/bundler')
local util_fs = require('src/lib/util/fs')
local os = require('os')

local f = util_fs.file(arg[1] or './src/main.lua')
local d = (arg[2] and util_fs.file(arg[2])) or util_fs.path('./dist', f.get_file())
local ok, msg = zeebo_bundler.build(f.get_fullfilepath(), d.get_fullfilepath())

if not ok then
    print(msg)
    if os then os.exit(1) end
end
