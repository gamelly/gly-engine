import { LuaFactory, LuaMultiReturn } from 'https://cdn.jsdelivr.net/npm/wasmoon@1.16.0/+esm'

if (!gly) {
    error('gly is not loaded!')
}

gly.wasmoon = async (game_file) => {
    const factory = new LuaFactory()
    const lua = await factory.createEngine()
    const engine_response = await fetch('./main.lua')
    const engine_lua = await engine_response.text()
    await lua.doString(engine_lua)
    
    gly.global.set('native_callback_init', lua.global.get('native_callback_init'))
    gly.global.set('native_callback_loop', lua.global.get('native_callback_loop'))
    gly.global.set('native_callback_draw', lua.global.get('native_callback_draw'))
    gly.global.set('native_callback_resize', lua.global.get('native_callback_resize'))
    gly.global.set('native_callback_keyboard', lua.global.get('native_callback_keyboard'))
    lua.global.set('native_draw_start', gly.global.get('native_draw_start'))
    lua.global.set('native_draw_flush', gly.global.get('native_draw_flush'))
    lua.global.set('native_draw_clear', gly.global.get('native_draw_clear'))
    lua.global.set('native_draw_color', gly.global.get('native_draw_color'))
    lua.global.set('native_draw_font', gly.global.get('native_draw_font'))
    lua.global.set('native_draw_rect', gly.global.get('native_draw_rect'))
    lua.global.set('native_draw_line', gly.global.get('native_draw_line'))
    lua.global.set('native_draw_image', gly.global.get('native_draw_image'))
    lua.global.set('native_dict_http', gly.global.get('native_dict_http'))
    lua.global.set('native_dict_json', gly.global.get('native_dict_json'))
    lua.global.set('native_dict_poly', gly.global.get('native_dict_poly'))
    lua.global.set('native_draw_text', (x, y, text) => {
        const native_draw_text = gly.global.get('native_draw_text')
        return LuaMultiReturn.from(native_draw_text(x, y, text))
    })

    gly.error('stop, canvas, console')
    gly.init('#gameCanvas')

    if (typeof game_file === 'string' && !game_file.includes('\n')) {
        const game_response = await fetch(game_file)
        gly.load(await game_response.text())
    } else {
        gly.load(game_file)
    }

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

    function updateSize() {
        gly.resize()
    }

    function updateKey(ev) {
        const key = keys.find(key => key[0] == ev.code)
        if (key) {
        gly.input(key[1], Number(ev.type === 'keydown'))
        }
    }

    function updateLoop() {
        window.requestAnimationFrame(updateLoop);
        gly.update((new Date()).getTime())
    }

    window.addEventListener("resize", updateSize);
    window.addEventListener('keydown', updateKey)
    window.addEventListener('keyup', updateKey)
    window.requestAnimationFrame(updateLoop);
}
