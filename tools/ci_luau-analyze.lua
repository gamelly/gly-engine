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
    return
end

cmd('./cli.sh build --bundler --core '..core)
cmd(replace..' --format "function native_callback" --replace "local function _native_callback"')
cmd('./cli.sh tool-package-del dist/main.lua core_src_third_party_json_rxi')
cmd('./cli.sh tool-package-del dist/main.lua core_src_lib_engine_api_encoder')
