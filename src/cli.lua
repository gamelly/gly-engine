local os = require('os')

print(os.execute('mkdir -p ./dist/'))
print(os.execute('cp examples/pong/game.lua dist/game.lua'))
print(os.execute('cp src/common/*.lua dist'))
print(os.execute('cp src/engine/ginga/core.lua dist/main.lua'))
print(os.execute('cp src/engine/ginga/main.ncl dist/main.ncl'))
