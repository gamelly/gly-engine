local cmd = function(c) assert(require('os').execute(c), c) end
local version = io.open('src/version.lua'):read('*a'):match('(%d+%.%d+%.%d+)')

cmd('rm -Rf ./dist')
cmd('./cli.sh build --core lite --bundler --dist ./dist/dist/')
cmd('cp ./packages/npm_gly-engine/README.md ./dist/README.md')
cmd('./cli.sh fs-replace ./packages/npm_gly-engine-lite/package.json ./dist/package.json --format "{{version}}" --replace '..version)
