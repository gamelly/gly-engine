local cmd = function(c) assert(require('os').execute(c), c) end
local core = arg[1] or 'native'

cmd('./cli.sh build --bundler --core '..core)
cmd('./cli.sh fs-replace dist/main.lua dist/main.lua --format "function native_callback" --replace "local function _native_callback"')
cmd('./cli.sh tool-package-del dist/main.lua third_party_json_rxi')
cmd('./cli.sh tool-package-del dist/main.lua lib_engine_api_encoder')
