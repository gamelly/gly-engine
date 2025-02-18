local util_decorator = require('src/lib/util/decorator')

--! @defgroup std
--! @{
--! @defgroup media
--! @{
--! @details streamming videos and music
--! @pre require @c media.video @c media.music
--!
--! @note You can also use @c mock.video and @c mock.music when the platform does not yet have support,@n
--! or you want the media to be optional and keep the api.
--!
--! @todo support as a playlist
--! @page media_video Video
--! @par Example
--! @code
--! std.media.video()
--!     :add('http://t.gamely.com.br/rick.mpg')
--!     :play()
--! @endcode
--!
--! @page media_music Music
--! @par Example
--! @code
--! std.media.music()
--!     :add('http://t.gamely.com.br/rick.mp3')
--!     :play()
--! @endcode

--! @renamefunc add
--! @hideparam media
--! @hideparam self
--! @hideparam func
local function media_add(media, func, self, src)
    func(media - 1, self.id - 1, src)
    return self
end

--! @renamefunc play
--! @hideparam media
--! @hideparam self
--! @hideparam func
local function media_play(media, func, self)
    func(media - 1, self.id - 1)
    return self
end

--! @renamefunc pause
--! @hideparam media
--! @hideparam self
--! @hideparam func
local function media_pause(media, func, self)
    func(media - 1, self.id - 1)
    return self
end

--! @renamefunc resize
--! @hideparam media
--! @hideparam self
--! @hideparam func
local function media_resize(media, func, self, width, height)
    func(media - 1, self.id - 1, width, height)
    return self
end

--! @renamefunc postion
--! @hideparam media
--! @hideparam self
--! @hideparam func
local function media_position(media, func, self, pos_x, pos_y)
    func(media - 1, self.id - 1, pos_x, pos_y)
    return self
end

--! @}
--! @}

local function media_channel(std, handler, mediatype, mediaid, max_channels)
    return function(id)
        local channels = std.media.channels[mediaid]
        id = id or 1

        if 0 >= id or id > max_channels then
            error('Please, do not do that!')
        end

        if not channels[id] then
            channels[id] = {
                id = id,
                add = util_decorator.prefix2(mediaid, handler.load, media_add),
                play = util_decorator.prefix2(mediaid, handler.play, media_play),
                pause = util_decorator.prefix2(mediaid, handler.pause, media_pause),
                resize = util_decorator.prefix2(mediaid, handler.resize, media_resize),
                position = util_decorator.prefix2(mediaid, handler.position, media_position)
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

local function install(std, engine, handlers, name)
    handler = handler or {}
    std.media = std.media or {}
    std.media.types = std.media.types or {}
    std.media.channels = std.media.channels or {}
    local mediatype = name:match('%w+%.(%w+)')
    local mediaid = #std.media.types + 1
    if not std.media[mediatype] then
        local max_channels = handlers.bootstrap and handlers.bootstrap(mediaid - 1, mediatype) or 8
        std.media.channels[mediaid] = {}
        std.media.types[mediaid] = mediatype
        std.media[mediatype] = media_channel(std, handlers, mediatype, mediaid, max_channels)
    end
end

local P = {
    install=install
}

return P
