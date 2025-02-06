local cmd = function(c) assert(require('os').execute(c), c) end

cmd('rm -Rf ./dist')
cmd('mkdir -p ./dist')
cmd('lua packages/lua_bundler/main.lua packages/lua_bundler/main.lua ./dist/bundler_cli.lua')
