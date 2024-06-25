local os = require('os')

local function isRunningInLove()
    for _, arg in ipairs(arg) do
        if arg == "--love" then
            return true
        end
    end
    return false
end

print(os.execute('mkdir -p ./dist/'))
print(os.execute('rm -Rf ./dist/*'))
print(os.execute('cp examples/pong/game.lua dist/game.lua'))
print(os.execute('cp src/common/*.lua dist'))
if isRunningInLove() then
    print(os.execute('cp src/engine/love2d/core.lua dist/main.lua'))
    print('love2d!')
else
    print(os.execute('cp src/engine/ginga/main.ncl dist/main.ncl'))
    print(os.execute('cp src/engine/ginga/core.lua dist/main.lua'))
    print('ginga!')
end
