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
        clear: (color) => {},
        color: (color) => {
            canvas_ctx.strokeStyle = color
            canvas_ctx.fillStyle = color
        },
        rect: (mode, x, y, w, h) => canvas_ctx.fillRect(x, y, w, h),
        font: (name, size) => {},
        text: (x, y, text) => canvas_ctx.fillText(text, x, y),
        poly: () => {}
    }

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
