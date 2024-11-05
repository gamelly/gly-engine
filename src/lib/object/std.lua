--! @short standard library object
--! @brief can be used as mock

local P = {
    milis = 0,
    delta = 0,
    math = {

    },
    draw = {
        image = function() end,
        clear = function () end,
        color = function () end,
        rect = function () end,
        text = function () end,
        font = function () end,
        line = function () end,
        poly = function () end,
        tui_text = function() end
    },
    game = {
        width = 1280,
        height = 720,
        register = function() end,
        title = function() end,
        reset = function () end,
        load = function() end,
        exit = function () end
    },
    key = {
        axis = {
            x = 0,
            y = 0,
            menu=0,
            up=0,
            down=0,
            left=0,
            right=0,
            a = 0,
            b = 0, 
            c = 0,
            d = 0
        },
        press = {
            menu=false,
            up=false,
            down=false,
            left=false,
            right=false,
            a=false,
            b=false,
            c=false,
            d=false
        }
    }
}

return P;
