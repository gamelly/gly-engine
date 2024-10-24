--! @short application object
--! @brief metatags, configs and code.

local P = {
    data={
        width=1280,
        height=720
    },
    meta={
        id='',
        title='',
        author='',
        company='',
        description='',
        version=''
    },
    config = {
        offset_x = 0,
        offset_y = 0,
        require = '',
        fps_max = 100,
        fps_show = 0,
        fps_drop = 5,
        fps_time = 5
    },
    callbacks={
        init=function () end,
        loop=function () end,
        draw=function () end,
        exit=function () end
    }
}

return P;
