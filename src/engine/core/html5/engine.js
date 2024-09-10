import { LuaFactory }  from 'https://cdn.jsdelivr.net/npm/wasmoon@1.16.0/+esm'

document.addEventListener('DOMContentLoaded', async () => {
    const factory = new LuaFactory()
    const lua = await factory.createEngine()

    const engine_response = await fetch('./main.lua')
    const game_response = await fetch('./game.lua')

    const engine_lua = await engine_response.text()
    const game_lua = await game_response.text()

    const body_element = document.querySelector('body')
    const canvas_element = document.querySelector('#gameCanvas')
    const canvas_ctx = canvas_element.getContext("2d")
    const canvas_close = [
        () => canvas_ctx.fill(),
        () => {
            canvas_ctx.closePath()
            canvas_ctx.stroke()
        },
        () => canvas_ctx.stroke()
    ]

    lua.global.set('native_draw_start', () => {})
    lua.global.set('native_draw_flush', () => {})
    lua.global.set('native_draw_clear', (color) => {
        canvas_ctx.fillStyle = '#' + color.toString(16).padStart(8, '0')
        canvas_ctx.fillRect(0, 0, canvas_element.width, canvas_element.height)
    })
    lua.global.set('native_draw_color', (color) => {
        const hex = '#' + color.toString(16).padStart(8, '0')
        canvas_ctx.strokeStyle = hex
        canvas_ctx.fillStyle = hex
    })
    lua.global.set('native_draw_line', (x1, y1, x2, y2) => {
        canvas_ctx.beginPath()
        canvas_ctx.moveTo(x1, y1)
        canvas_ctx.lineTo(x2, y2)
        canvas_ctx.stroke()
    })
    lua.global.set('native_draw_rect', (mode, x, y, w, h) => mode === 1?
        canvas_ctx.strokeRect(x, y, w, h):
        canvas_ctx.fillRect(x, y, w, h)
    )
    lua.global.set('native_draw_font', (name, size) => {})
    lua.global.set('native_draw_text', (x, y, text) => {
        const { width } = canvas_ctx.measureText(text || x)
        x && y && canvas_ctx.fillText(text, x, y)
        return width
    })
    lua.global.set('native_dict_poly', {
        poly2: (mode, verts, x, y, scale = 1, angle = 0, ox = 0, oy = 0) => {
            let index = 0
            canvas_ctx.beginPath()
            while (index < verts.length) {
                const px = verts[index];
                const py = verts[index + 1];
                const xx = x + ((ox - px) * -scale * Math.cos(angle)) - ((ox - py) * -scale * Math.sin(angle));
                const yy = y + ((oy - px) * -scale * Math.sin(angle)) + ((oy - py) * -scale * Math.cos(angle));
                if (index < 2) {
                    canvas_ctx.moveTo(xx, yy)
                } else {
                    canvas_ctx.lineTo(xx, yy)
                }
                index = index + 2;
            }
            canvas_close[mode]()
        }
    })
    lua.global.set('native_dict_http', {
        handler: (self) => {
           const method = self.method
           const headers = new Headers(self.headers_dict)
           const params = new URLSearchParams(self.params_dict)
           const url = `${self.url}` + '?' + params.toString()
           const body = ['HEAD', 'GET'].includes(method)? null: self.body_content
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
    })

    if (body_element.clientWidth > body_element.clientHeight) {
        canvas_element.height = body_element.clientHeight
        canvas_element.width = body_element.clientWidth
    }
    else {
        canvas_element.height = Math.floor(body_element.clientHeight / 2)
        canvas_element.width = body_element.clientWidth
    }

    await lua.doString(engine_lua)
    const engine_callbacks = {
        init: lua.global.get('native_callback_init'),
        update: lua.global.get('native_callback_loop'),
        draw: lua.global.get('native_callback_draw'),
        keyboard: lua.global.get('native_callback_keyboard'),
    }
    engine_callbacks.init(canvas_element.width, canvas_element.height, game_lua)

    setTimeout(() => {
        const keys = [
            [403, 'red'],
            [404, 'green'],
            [405, 'yellow'],
            [406, 'blue'],
            ['KeyZ', 'red'],
            ['KeyX', 'green'],
            ['KeyC', 'yellow'],
            ['KeyV', 'blue'],
            ['Enter', 'enter'],
            ['ArrowUp', 'up'],
            ['ArrowDown', 'down'],
            ['ArrowLeft', 'left'],
            ['ArrowRight', 'right'],
        ];
    
        const keyHandler = (ev) => keys
            .filter(key => [ev.code, ev.keyCode].includes(key[0]))
            .map(key => engine_callbacks.keyboard(key[1], Number(ev.type === 'keydown')))

        window.addEventListener('keydown', keyHandler)
        window.addEventListener('keyup', keyHandler)
    }, 100)
       
    const tick = () => {
        const now = new Date()
        const milis = now.getTime()
        engine_callbacks.update(milis)
        engine_callbacks.draw()
        window.requestAnimationFrame(tick)
    }

    tick()
})
