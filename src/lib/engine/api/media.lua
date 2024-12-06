local util_decorator = require('src/lib/util/decorator')

--! @defgroup std
--! @{
--! @defgroup media
--! @{
--! @details streamming videos and music
--! @pre require @c media
--! @details
--!
--! @todo support as a playlist
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

local function media_channel(std, handler)
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

            if std.node then
                channels[id].node = std.node.load({})
                channels[id].apply = function()
                    local node = channels[id].node
                    local depth = 0
                    local offset_x = 0
                    local offset_y = 0
                    while node and depth < 100 do
                        offset_x = offset_x + node.config.offset_x
                        offset_y = offset_y + node.config.offset_y
                        node = node.config.parent
                        depth = depth + 1
                    end
                    media_position(handler.position, channels[id], offset_x, offset_y)
                    media_resize(handler.resize, channels[id], channels[id].node.data.width, channels[id].node.data.height)
                end
            end
        end

        return channels[id]
    end
end

local function install(std, engine, handlers)
    std.media = std.media or {}
    std.media.video = media_channel(std, handlers)
end

local P = {
    install=install
}

return P
