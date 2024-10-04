local cmd = function(c) assert(require('os').execute(c), c) end
local version = io.open('src/cli/commands/info.lua'):read('*a'):match('(%d+%.%d+%.%d+)')

cmd('npm install -g demoon > /dev/null 2>/dev/null')
cmd('rm -Rf ./dist')
cmd('mkdir -p ./dist/dist')
cmd('cp ./npm/core-native-html5/README.md ./dist/README.md')
cmd('cp ./src/engine/core/html5/core-native-html5.js ./dist/dist/index.js')
cmd('./cli.sh fs-replace npm/core-native-html5/package.json ./dist/package.json --format "{{version}}" --replace '..version)
