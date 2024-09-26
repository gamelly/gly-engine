local cmd = function(c) assert(require('os').execute(c), c) end
local version = io.open('src/cli/commands/info.lua'):read('*a'):match('(%d+%.%d+%.%d+)')

cmd('rm -Rf ./dist')
cmd('./cli.sh build --core native --bundler')
cmd('mkdir -p ./dist/dist')
cmd('mv ./dist/main.lua ./dist/dist/main.lua')
cmd('cp ./npm/gly-engine/README.md ./dist/README.md')
cmd('./cli.sh fs-replace npm/gly-engine/package.json ./dist/package.json --format "{{version}}" --replace '..version)
