local util_decorator = require('src/lib/util/decorator')

--! @defgroup std
--! @{
--! @defgroup log
--! @{
--! @call code
local logging_types = {
    'none', 'fatal', 'error', 'warn', 'debug', 'info'
}
--! @call endcode

--! @hideparam engine
--! @hideparam lpf
--! @hideparam lpn
local function level(engine, lpf, lpn, level)
    local l = lpf[level] or lpn[level] or level
    if type(l) ~= 'number' or l <= 0 or l > #logging_types then
        error('logging level not exist:'..tostring(level)) 
    end
    engine.loglevel = l
end

--! @hideparam std
--! @hideparam engine
local function init(std, engine, printers)
    local index = 1
    local level_per_func = {}
    local level_per_name = {}
    while index <= #logging_types do
        local ltype = logging_types[index]
        local lfunc = function(message)
            if engine.loglevel >= index then
                printers[ltype](message)
            end
        end
        level_per_func[lfunc] = index - 1
        level_per_name[ltype] = index - 1
        std.log[ltype] = lfunc
        index = index + 1
    end
    std.log.level = util_decorator.prefix3(engine, level_per_func, level_per_func, level)
end

--! @}
--! @}

local function install(std, engine, printers)
    std.log = std.log or {}
    engine.loglevel = #logging_types
    std.log.init = util_decorator.prefix2(std, engine, init)
    std.log.init(printers)
end

local P = {
    install = install
}

return P
