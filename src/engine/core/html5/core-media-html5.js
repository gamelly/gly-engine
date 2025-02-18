const media = {
    type: [],
    elements: {
        video: new Array(5).fill(null),
        music: new Array(5).fill(null),
    },
    old_global_get: gly.global.get,
    global: {
        native_media_bootstrap: (mediaid, mediatype) => {
            media.type[mediaid] = mediatype
            return 5;
        },
        native_media_load: (mediaid, channel, url) => {
            const t = media.type[mediaid]
            if (!media.elements[t][channel]) {
                const eltype = t == 'video'? t: 'audio'
                const video = document.createElement(eltype)
                document.querySelector('main').appendChild(video)
                media.elements[t][channel] = video
            }
            media.elements[t][channel].src = url
            media.elements[t][channel].load()
            if (t == 'video') {
                media.elements[t][channel].style.zIndex = -channel -1
            }
        },
        native_media_position: (mediaid, channel, x, y) => {
            const t = media.type[mediaid]
            if (!media.elements[t][channel] && t != 'video')  {
                return;
            }
            media.elements[t][channel].style.left = `${x}px`
            media.elements[t][channel].style.top = `${y}px`
        },
        native_media_resize: (mediaid, channel, width, height) => {
            const t = media.type[mediaid]
            if (!media.elements[t][channel] && t != 'video') {
                return;
            }
            media.elements[t][channel].style.width = `${width}px`
            media.elements[t][channel].style.height = `${height}px`
        },
        native_media_play: (mediaid, channel) => {
            const t = media.type[mediaid]
            if (!media.elements[t][channel]) {
                return;
            }
            media.elements[t][channel].play()
        },
        native_media_pause: (mediaid, channel) => {
            const t = media.type[mediaid]
            if (!media.elements[t][channel]) {
                return;
            }
            media.elements[t][channel].pause()
        },
        native_media_time: (mediaid, channel, time) => {
            const t = media.type[mediaid]
            const video = media.elements[t][channel]
            if (!video) {
                return;
            }
            if (video.fastSeek) {
                video.fastSeek(time)
            } else {
                video.currentTime = time
            }
        }
    }
}

gly.global.get = (var_name) => {
    if (media.global[var_name]) {
        return media.global[var_name];
    }
    return media.old_global_get(var_name)
}
