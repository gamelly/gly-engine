--! @file src/object/std.lua
--! @short standard library object
--! @brief can be used as mock

local P = {
    math = {

    },
    draw = {
        clear = function () end,
        color = function () end,
        rect = function () end,
        text = function () end,
        font = function () end,
        line = function () end,
        poly = function () end
    },
    game = {
        reset = function () end,
        exit = function () end
    },
    key = {
        press = {
            up=0,
            down=0,
            left=0,
            right=0,
            red=0,
            green=0,
            yellow=0,
            blue=0,
            enter=0
        }
    }
}

return P;
