local cmd = function(c) assert(require('os').execute(c), c) end
local version = io.open('src/cli/commands/info.lua'):read('*a'):match('(%d+%.%d+%.%d+)')

cmd('rm -Rf ./dist')
cmd('mkdir -p ./dist/dist')
cmd('cp ./packages/npm_core-native-html5/README.md ./dist/README.md')
cmd('cp ./src/engine/core/html5/core-native-html5.js ./dist/dist/index.js')
cmd('./cli.sh fs-replace ./packages/npm_core-native-html5/package.json ./dist/package.json --format "{{version}}" --replace '..version)
