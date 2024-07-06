--! @file src/object/application.lua
--! @short application object
--! @brief metatags, configs and code.

local P = {
    meta={
        title='',
        description='',
        version=''
    },
    config = {
        fps_max = 100,
        fps_show = 0,
        fps_drop = 2,
        fps_time = 1
    },
    callbacks={
        init=function () end,
        loop=function () end,
        draw=function () end,
        exit=function () end
    }
}

return P;
