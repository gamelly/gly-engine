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
        require = '',
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
