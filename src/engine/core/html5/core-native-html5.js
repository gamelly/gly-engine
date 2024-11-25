const engine = {
    stop: false,
    file: './main.lua',
    milis: null,
    pause: false,
    error: {
        callback: null,
        capture: false,
        console: false,
        canvas: false,
        stop: false   
    },
    font: {
        previous_size: 8,
        previous_name: 'sans',
        change: true,
        name: 'sans',
        size: 8,
        apply: () => {
            engine.font.previous_name = engine.font.name
            engine.font.previous_size = engine.font.size
            engine.canvas_ctx.font = `${engine.font.size}px ${engine.font.name}`;
            engine.canvas_ctx.textBaseline = 'top'
            engine.canvas_ctx.textAlign = 'left'
            engine.font.change = false
        },
    },
    images: {},
    listen: {},
    global: {
        native_draw_start: () => {
            engine.canvas_ctx.clearRect(0, 0, engine.canvas_element.width, engine.canvas_element.height)
        },
        native_draw_flush: () => {},
        native_draw_clear: (color, x, y, w, h) => {
            engine.canvas_ctx.fillStyle = '#' + color.toString(16).padStart(8, '0')
            engine.canvas_ctx.fillRect(x, y, w, h)
        },
        native_draw_color: (color) => {
            const hex = '#' + color.toString(16).padStart(8, '0')
            engine.canvas_ctx.strokeStyle = hex
            engine.canvas_ctx.fillStyle = hex
        },
        native_draw_line: (x1, y1, x2, y2) => {
            engine.canvas_ctx.beginPath()
            engine.canvas_ctx.moveTo(x1, y1)
            engine.canvas_ctx.lineTo(x2, y2)
            engine.canvas_ctx.stroke()
        },
        native_draw_rect: (mode, x, y, w, h) => {
            mode === 1 ? engine.canvas_ctx.strokeRect(x, y, w, h) : engine.canvas_ctx.fillRect(x, y, w, h)
        },
        native_text_font_name: (name) => {
            engine.font.name = name
            engine.font.change = true
        },
        native_text_font_size: (size) => {
            engine.font.size = size
            engine.font.change = true
        },
        native_text_font_default: (font_id) => {
            engine.font.name = 'sans'
            engine.font.change = true
        },
        native_text_font_previous: () => {
            engine.font.name = engine.font.previous_name
            engine.font.size = engine.font.previous_size
            engine.font.change = true
        },
        native_text_print: (x, y, text) => {
            if (engine.font.change) {
                engine.font.apply()
            }
            engine.canvas_ctx.fillText(text, x, y)
        },
        native_text_mensure: (text) => {
            if (engine.font.change) {
                engine.font.apply()
            }
            const { width, actualBoundingBoxAscent, actualBoundingBoxDescent } = engine.canvas_ctx.measureText(text)
            return [width, actualBoundingBoxAscent + actualBoundingBoxDescent]
        },
        native_draw_image: (src, x, y) => {
            if (!(src in engine.images)) {
                engine.images[src] = document.createElement('img')
                engine.images[src].src = src
                engine.images[src].onload = function() {
                    engine.images[src].attributes.done = 'true'
                }
            }
            if (engine.images[src].attributes.done) {
                engine.canvas_ctx.drawImage(engine.images[src], x, y)
            }
        },
        native_get_system_language: () => {
            return navigator.language
        },
        native_dict_poly: {
            poly2: (mode, verts, x, y, scale, angle, ox, oy) => {
                let index = 0
                engine.canvas_ctx.beginPath()
                while (index < verts.length) {
                    const px = verts[index];
                    const py = verts[index + 1];
                    const xx = x + ((ox - px) * -scale * Math.cos(angle)) - ((oy - py) * -scale * Math.sin(angle));
                    const yy = y + ((oy - px) * -scale * Math.sin(angle)) + ((ox - py) * -scale * Math.cos(angle));
                    if (index < 2) {
                        engine.canvas_ctx.moveTo(xx, yy)
                    } else {
                        engine.canvas_ctx.lineTo(xx, yy)
                    }
                    index += 2;
                }
                engine.canvas_close[mode]()
            }
        },
        native_dict_http: {
            handler: (self) => {
                const method = self.method
                const headers = new Headers(self.headers_dict)
                const params = new URLSearchParams(self.params_dict)
                const url = `${self.url}` + '?' + params.toString()
                const body = ['HEAD', 'GET'].includes(method) ? null : self.body_content
                self.promise()
                fetch(url, {
                    body: body,
                    method: method,
                    headers: headers
                })
                .then((response) => {
                    self.set('ok', response.ok)
                    self.set('status', response.status)
                    return response.text()
                })
                .then((content) => {
                    self.set('body', content)
                    self.resolve()
                })
                .catch((error) => {
                    self.set('ok', false)
                    self.set('error', `${error}`)
                    self.resolve()
                })
            }
        },
        native_dict_json: {
            encode: JSON.stringify,
            decode: JSON.parse
        }
    }    
}

function errorController(func) {
    if (engine.stop) {
        return
    }
    if (!engine.error.capture) {
        return func()
    }
    try {
        func()
    }
    catch(e) {
        if (engine.error.console) {
            console.log(e)
        }
        if (engine.error.stop) {
            engine.stop = true
        }
        if (engine.error.canvas) {
            engine.global.native_draw_start()
            engine.global.native_draw_clear(0x0000FFFF)
            engine.global.native_draw_color(0xFFFFFFFF)
            engine.global.native_text_font_size(8)
            engine.global.native_text_font_default(1)
            engine.global.native_text_print(8, 16, 'Fatal ERROR')
            engine.global.native_text_print(8, 32, e.toString())
        }
        if (engine.error.callback) {
            engine.error.callback(e)
        }
    }
}

function resizeCanvas() {
    if (engine.body_element.clientWidth > engine.body_element.clientHeight) {
        engine.canvas_element.height = engine.body_element.clientHeight
        engine.canvas_element.width = engine.body_element.clientWidth
    }
    else {
        engine.canvas_element.height = Math.floor(engine.body_element.clientHeight / 2)
        engine.canvas_element.width = engine.body_element.clientWidth
    }
}

const gly = {
    init: (canvas_selector) => {
        engine.body_element = document.querySelector('body')
        engine.canvas_element = document.querySelector(canvas_selector)
        engine.canvas_ctx = engine.canvas_element.getContext("2d")
        engine.canvas_close = [
            () => engine.canvas_ctx.fill(),
            () => {
                engine.canvas_ctx.closePath()
                engine.canvas_ctx.stroke()
            },
            () => engine.canvas_ctx.stroke()
        ]
        resizeCanvas()
    },
    load: (game_file) => {
        const {width, height} = engine.canvas_element
        errorController(() => {
            engine.listen.native_callback_init(width, height, game_file)
        })  
    },
    input: (key, value) => {
        errorController(() => {
            engine.listen.native_callback_keyboard(key, value)
        })
    },
    error: (behavior, error_callback) => {
        const silent = behavior.includes('silent')
        engine.error.capture = !behavior.includes('default')
        engine.error.console = !silent && behavior.includes('console')
        engine.error.canvas = !silent && behavior.includes('canvas')
        engine.error.stop = !silent && behavior.includes('stop')
        engine.error.callback = error_callback
    },
    resize: () => {
        resizeCanvas()
        const {width, height} = engine.canvas_element
        errorController(() => {
            engine.listen.native_callback_resize(width, height)
        })
    },
    pause: () => {
        engine.pause = true
    },
    resume: () => {
        engine.pause = false
    },
    update: (milis) => {
        if (!engine.pause) {
            errorController(() => {
                engine.listen.native_callback_loop(milis ?? 16)
                engine.listen.native_callback_draw()
            })
        }
    },
    update_uptime: (milis) => {
        engine.milis = engine.milis ?? milis ?? 0
        const dt = milis - engine.milis
        engine.milis = milis
        gly.update(dt)
    },
    engine: {
        set: (file_name) => engine.file = file_name,
        get: () => engine.file
    },
    global: {
        set: (var_name, value) => {
            engine.listen[var_name] = value
        },
        get: (var_name) => {
            return engine.global[var_name]
        }
    }
}

if (typeof exports === 'object' && typeof module !== 'undefined') {
    module.exports = gly;
} else if (typeof define === 'function' && define.amd) {
    define([], function() {
        return gly;
    });
} else {
    window.gly = gly;
}
