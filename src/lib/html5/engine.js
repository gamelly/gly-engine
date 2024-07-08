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
            canvas_ctx.fillStyle = color,
            canvas_ctx.fillRect(0, 0, canvas_element.width, canvas_element.height)
        },
        color: (color) => {
            canvas_ctx.strokeStyle = color
            canvas_ctx.fillStyle = color
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
            const { width } = canvas_ctx.measureText(text)
            canvas_ctx.fillText(text, x, y)
            return width
        },
        poly: () => {}
    }

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
            engine_callbacks.keyboard(key[1], Number(ev.type === 'keydown'))
        }

        window.addEventListener('keydown', keyHandler)
        window.addEventListener('keyup', keyHandler)
    }, 100)

    lua.global.set('game_lua', game_lua)
    lua.global.set('browser_canvas', canvas_std)
    const engine_callbacks = await lua.doString(engine_lua)
    engine_callbacks.init(1260, 720)
       
    const tick = () => {
        const milis = (new Date()).getMilliseconds()
        const delay = engine_callbacks.update(milis)
        engine_callbacks.draw()
        setTimeout(tick, delay)
    }

    tick()
})
