import { LuaFactory }  from 'https://cdn.jsdelivr.net/npm/wasmoon@1.16.0/+esm'

document.addEventListener('DOMContentLoaded', async () => {
    const factory = new LuaFactory()
    const lua = await factory.createEngine()

    const engine_response = await fetch('./main.lua')
    const game_response = await fetch('./game.lua')

    const engine_lua = await engine_response.text()
    const game_lua = await game_response.text()

    const canvas_element = document.querySelector('#gameCanvas')
    const canvas_ctx = canvas_element.getContext("2d")
    const canvas_std = {
        clear: (color) => {
            canvas_ctx.fillStyle = '#' + color.toString(16).padStart(8, '0')
            canvas_ctx.fillRect(0, 0, canvas_element.width, canvas_element.height)
        },
        color: (color) => {
            const hex = '#' + color.toString(16).padStart(8, '0')
            canvas_ctx.strokeStyle = hex
            canvas_ctx.fillStyle = hex
        },
        line: (x1, y1, x2, y2) => {
            canvas_ctx.beginPath()
            canvas_ctx.moveTo(x1, y1)
            canvas_ctx.lineTo(x2, y2)
            canvas_ctx.stroke()
        },
        rect: (mode, x, y, w, h) => mode === 1?
            canvas_ctx.strokeRect(x, y, w, h):
            canvas_ctx.fillRect(x, y, w, h),
        font: (name, size) => {},
        text: (x, y, text) => {
            const { width } = canvas_ctx.measureText(text || x)
            x && y && canvas_ctx.fillText(text, x, y)
            return width
        },
        poly: (mode, verts, x, y, scale = 1, angle = 0, ox = 0, oy = 0) => {
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
            canvas_ctx.stroke()
        }
    }

    lua.global.set('game_lua', game_lua)
    lua.global.set('browser_canvas', canvas_std)
    const engine_callbacks = await lua.doString(engine_lua)
    engine_callbacks.init(1260, 720)

    setTimeout(() => {
        const keys = [
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
    
        const keyHandler = (ev) => {
            const key = keys.find(key => key[0] == ev.code)
            key && engine_callbacks.keyboard(key[1], Number(ev.type === 'keydown'))
        }

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

    window.requestAnimationFrame(tick)
})
