local util_decorator = require('src/lib/util/decorator')

--! @defgroup std
--! @{
--! @defgroup media
--! @{
--! @details streamming videos and music
--! @pre require @c media
--! @details
--!
--! @page media_video Video
--! @par Example
--! @code
--! std.media.video()
--!     :add('http://t.gamely.com.br/rick.mpg')
--!     :loop()
--!     :play()
--! @endcode

--! @renamefunc add
--! @hideparam self
--! @hideparam func
local function media_add(func, self, src)
    func(self.id - 1, src)
    return self
end

--! @renamefunc play
--! @hideparam self
--! @hideparam func
local function media_play(func, self)
    func(self.id - 1)
    return self
end

--! @renamefunc pause
--! @hideparam self
--! @hideparam func
local function media_pause(func, self)
    func(self.id - 1)
    return self
end

--! @renamefunc resize
--! @hideparam self
--! @hideparam func
local function media_resize(func, self, width, height)
    func(self.id - 1, width, height)
    return self
end

--! @renamefunc postion
--! @hideparam self
--! @hideparam func
local function media_position(func, self, pos_x, pos_y)
    func(self.id - 1, pos_x, pos_y)
    return self
end

--! @}
--! @}

local channels = {}

local function media_channel(handler)
    return function(id)
        id = id or 1

        if 0 >= id or id > 8 then
            error('Please, do not do that!')
        end

        if not channels[id] then
            channels[id] = {
                id = id,
                add = util_decorator.prefix1(handler.load, media_add),
                play = util_decorator.prefix1(handler.play, media_play),
                pause = util_decorator.prefix1(handler.pause, media_pause),
                resize = util_decorator.prefix1(handler.resize, media_resize),
                position = util_decorator.prefix1(handler.position, media_position)
            }
        end

        return channels[id]
    end
end

local function install(std, engine, handlers)
    std.media = std.media or {}
    std.media.video = media_channel(handlers)
end

local P = {
    install=install
}

return P
