local cmd = function(c) assert(require('os').execute(c), c) end
local core = arg[1] or 'native'

local replace = './cli.sh fs-replace dist/main.lua dist/main.lua'

if core == 'cli' then
    cmd('./cli.sh bundler src/cli/main.lua')
    cmd(replace..' --format "require%(\'src/engine/core/repl/main\'%)" --replace ""')
    cmd(replace..' --format "BOOTSTRAP_DISABLE = true" --replace ""')
    cmd(replace..' --format "string.dump" --replace "string.format"')
    cmd(replace..' --format "arg = {args.game}" --replace ""')    
    cmd(replace..' --format "arg = nil" --replace ""')    
    cmd('./cli.sh tool-package-mock mock/json.lua dist/main.lua third_party_json_rxi')
    cmd('./cli.sh tool-package-mock mock/lustache.lua dist/main.lua third_party_lustache_olivinelabs')
    return
end

if ('asteroids pong'):find(core) then
    cmd('./cli.sh bundler samples/'..core..'/game.lua')
    cmd('mv dist/game.lua dist/main.lua')
    return
end

cmd('./cli.sh build --bundler --enterprise --core '..core)
cmd(replace..' --format "function native_callback" --replace "local function _native_callback"')
cmd('./cli.sh tool-package-mock mock/json.lua dist/main.lua third_party_json_rxi')
