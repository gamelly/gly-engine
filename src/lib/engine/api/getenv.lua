local util_decorator = require('src/lib/util/decorator')
local os = require('os')

--! @defgroup std
--! @{

--! @todo getenv build variables
local function getenv(engine, varname)
    local fixedenvs = engine.root.envs
    if fixedenvs[varname] then
        return fixedenvs[varname]
    end
    if os and os.getenv then
        return os.getenv(varname)
    end
    return nil
end

--! @}

local function install(std, engine)
    std.getenv = util_decorator.prefix1(engine, getenv)
end

local P = {
    install = install
}

return P
