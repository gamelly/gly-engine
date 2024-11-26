local cmd = function(c) assert(require('os').execute(c), c) end
local version = io.open('src/version.lua'):read('*a'):match('(%d+%.%d+%.%d+)')

cmd('npm install -g demoon > /dev/null 2>/dev/null')
cmd('rm -Rf ./dist')
cmd('./cli.sh cli-build')
cmd('mkdir -p ./dist/bin')
cmd('npx demoon ./dist/cli.lua compiler ./dist/cli.lua --dist ./dist/cli.out')
cmd('echo "#!/usr/bin/env -S npx demoon" > ./dist/header.txt')
cmd('cat ./dist/header.txt ./dist/cli.out > dist/bin/gly-cli')
cmd('chmod +x ./dist/bin/gly-cli')
cmd('rm ./dist/cli.lua ./dist/header.txt ./dist/cli.out')
cmd('./cli.sh fs-replace ./packages/npm_gly-cli/package.json ./dist/package.json --format "{{version}}" --replace '..version)
cmd('./cli.sh fs-replace README.md ./dist/README.md --format "lua cli.lua" --replace "npx gly-cli"')
