const media = {
    elements: new Array(5).fill(null),
    old_global_get: gly.global.get,
    global: {
        native_media_load: (channel, url) => {
            if (!media.elements[channel]) {
                const video = document.createElement('video')
                document.querySelector('main').appendChild(video)
                media.elements[channel] = video
            }
            media.elements[channel].src = url
            media.elements[channel].load()
            media.elements[channel].style.zIndex = -channel -1
        },
        native_media_position: (channel, x, y) => {
            if (!media.elements[channel]) {
                return;
            }
            media.elements[channel].style.left = `${x}px`
            media.elements[channel].style.top = `${y}px`
        },
        native_media_resize: (channel, width, height) => {
            if (!media.elements[channel]) {
                return;
            }
            media.elements[channel].style.width = `${width}px`
            media.elements[channel].style.height = `${height}px`
        },
        native_media_play: (channel) => {
            if (!media.elements[channel]) {
                return;
            }
            media.elements[channel].play()
        },
        native_media_pause: (channel) => {
            if (!media.elements[channel]) {
                return;
            }
            media.elements[channel].pause()
        },
        native_media_time: (channel, time) => {
            const video = media.elements[channel]
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
