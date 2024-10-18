local util_decorator = require('src/lib/util/decorator')

--! @defgroup std
--! @{
--! @defgroup game
--! @{

--! @hideparam std
local function reset(std)
    std.bus.emit('exit')
    std.bus.emit('init')
end

--! @hideparam std
--! @hideparam func
local function exit(std, func)
    std.bus.emit('exit')
    if func then
        func()
    end
end

--! @hideparam func
local function title(func, window_name)
    if func then
        func(window_name)
    end
end

--! @}
--! @}

--! @cond
local function install(std, engine, config)
    std = std or {}
    std.game = std.game or {}

    std.game.title = util_decorator.prefix1(config.set_title, title)
    std.game.exit = util_decorator.prefix2(std, config.quit, exit)
    std.game.reset = util_decorator.prefix1(std, reset)
    std.game.get_fps = config.fps

    return std.game
end
--! @endcond

local P = {
    install=install
}

return P
