<div align="center">
<h1>:mechanical_arm:<br>GLY Engine<br><sup><sub>powered by <a href="https://gamely.com.br" target="_blank">gamely.com.br</a></sub></sup></h1>
</div>

> create your own game-engine with just javascript. 

## Example

### The Game
```javascript
function awesome_game(loop, draw, keys) {
    let color = 0x00FFFFFF

    loop.callback(() => {

    })
    draw.callback(() => {
        draw.color(0x000000FF)
        draw.rect(0, 0, 0, draw.width, draw.heigth)
        draw.color(color)
        draw.rect(0, 10, 20, 30, 40)
    })
    keys.callback((key, press) => {
        if (key == 'KeyZ' && press) {
            color = 0xFF0000FF
        }
    })
}
```

### The Engine

```javascript

const engine = {
    loop: {
        callback: (f) => {engine.callback_loop = f}
    },
    draw: {
        color: gly.global.get('native_draw_color'),
        rect: gly.global.get('native_draw_rect'),
        callback: (f) => {engine.callback_draw = f}
    },
    keys: {
        callback: (f) => {engine.callback_keys = f}
    },
}

gly.global.set('native_callback_init', (width, heigth, game) => {
    game(engine.loop, engine.draw, engine.keys)
    engine.draw.width = width
    engine.draw.heigth = heigth
})

gly.init('#gameCanvas')
gly.load(awesome_game)

gly.global.set('native_callback_loop', engine.callback_loop)
gly.global.set('native_callback_draw', engine.callback_draw)
gly.global.set('native_callback_keyboard', engine.callback_keys)

function updateKey(ev) {
    gly.input(ev.code, ev.type === 'keydown')
}
window.addEventListener('keydown', updateKey)
window.addEventListener('keyup', updateKey)

function tick() {
    gly.update()
    window.requestAnimationFrame(tick)
}
tick()
```

## Cheatcheet

### Direct API

 * **gly.init(canvas_selector)**
 * **gly.load(game_file_text)**
 * **gly.input(key, value)** 
 * **gly.error(behavior)**
 * **gly.widescreen(toggle)**
 * **gly.resize(width, height)**
 * **gly.update()**
 * **gly.update_uptime(milis)**
 * **gly.global.set(name, value)**
 * **gly.global.get(name)**

### Functions

 * **native_draw_start()**
 * **native_draw_flush()**
 * **native_draw_clear(color, x, y, w, h)**
 * **native_draw_color(color)**
 * **native_draw_font(name, size)**
 * **native_draw_rect(mode, x, y, width, heigth)**
 * **native_draw_line(x1, y1, x2, y2)**
 * **native_draw_poly2(mode, verts, x, y, scale, angle, ox, oy)**
 * **native_text_print(x, y, text)**
 * **native_text_font_size(size)**
 * **native_text_font_name(name)**
 * **native_text_font_default(font_id)**
 * **native_text_font_previous()**
 * **native_http_handler**

### Callbacks

 * **native_callback_loop(milis)**
 * **native_callback_draw()**
 * **native_callback_resize(width, height)**
 * **native_callback_keyboard(key, value)**
 * **native_callback_http(self, req_id)**
