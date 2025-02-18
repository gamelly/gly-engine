if (!gly) {
    error('gly is not loaded!')
}

gly.bootstrap = async (game_file) => {
    let engine_lua = gly.engine.get()

    fengari.lualib.luaL_openlibs(fengari.L);

    const define_lua_callback = (func_name, func_decorator) => {
        gly.global.set(func_name, (a, b, c, d, e, f) => {
            fengari.lua.lua_getglobal(fengari.L, fengari.to_luastring(func_name))
            const func = func_decorator ?? (() => 0)
            const res = func(a, b, c, d, e, f) ?? 0;
            if (fengari.lua.lua_pcall(fengari.L, res, 0, 0) !== 0) {
                const error_message = fengari.lua.lua_tostring(fengari.L, -1)
                throw error_message && fengari.to_jsstring(error_message) || func_name
            }
        })
    }

    const define_lua_func = (func_name, func_decorator) => {
        const func_native = gly.global.get(func_name);
        fengari.lua.lua_pushcfunction(fengari.L, () => {
            try {
                const res = func_decorator(func_native);
                return res ?? 0;
            } catch (e) {
                throw `${e} in ${func_name}`
            }
        });
        fengari.lua.lua_setglobal(fengari.L, fengari.to_luastring(func_name));
    }

    const httplua = (reqid, key, data) => {
        const params = data !== undefined? 3: 2
        fengari.lua.lua_getglobal(fengari.L, fengari.to_luastring('native_callback_http'))
        fengari.lua.lua_pushinteger(fengari.L, reqid);
        fengari.lua.lua_pushstring(fengari.L, fengari.to_luastring(key));
        if (typeof data == 'string') {
            fengari.lua.lua_pushstring(fengari.L, fengari.to_luastring(data));
        }
        if (typeof data == 'number') {
            fengari.lua.lua_pushnumber(fengari.L, data);
        }
        if (typeof data == 'boolean') {
            fengari.lua.lua_pushboolean(fengari.L, data);
        }
        if(fengari.lua.lua_pcall(fengari.L, params, 1, 0) !== 0){
            throw fengari.to_jsstring(fengari.lua.lua_tostring(fengari.L, -1))
        }
        if (fengari.lua.lua_type(fengari.L, -1) == fengari.lua.LUA_TSTRING) {
            return fengari.to_jsstring(fengari.lua.lua_tostring(fengari.L, -1));
        }
    }

    define_lua_func('native_draw_start', (func) => {
        func();
    });
    
    define_lua_func('native_draw_flush', (func) => {
        func();
    });
    
    define_lua_func('native_draw_clear', (func) => {
        const color = fengari.lua.lua_tointeger(fengari.L, 1) >>> 0;;
        const x = fengari.lua.lua_tonumber(fengari.L, 2);
        const y = fengari.lua.lua_tonumber(fengari.L, 3);
        const w = fengari.lua.lua_tonumber(fengari.L, 4);
        const h = fengari.lua.lua_tonumber(fengari.L, 5);
        func(color, x, y, w, h);
    });
    
    define_lua_func('native_draw_color', (func) => {
        const color = fengari.lua.lua_tointeger(fengari.L, 1) >>> 0;
        func(color);
    });
    
    define_lua_func('native_draw_rect', (func) => {
        const mode = fengari.lua.lua_tointeger(fengari.L, 1);
        const x = fengari.lua.lua_tonumber(fengari.L, 2);
        const y = fengari.lua.lua_tonumber(fengari.L, 3);
        const w = fengari.lua.lua_tonumber(fengari.L, 4);
        const h = fengari.lua.lua_tonumber(fengari.L, 5);
        func(mode, x, y, w, h);
    });
    
    define_lua_func('native_draw_line', (func) => {
        const x1 = fengari.lua.lua_tonumber(fengari.L, 1);
        const y1 = fengari.lua.lua_tonumber(fengari.L, 2);
        const x2 = fengari.lua.lua_tonumber(fengari.L, 3);
        const y2 = fengari.lua.lua_tonumber(fengari.L, 4);
        func(x1, y1, x2, y2);
    });
    
    define_lua_func('native_draw_image', (func) => {
        const src = fengari.to_jsstring(fengari.lua.lua_tostring(fengari.L, 1));
        const x = fengari.lua.lua_tonumber(fengari.L, 2);
        const y = fengari.lua.lua_tonumber(fengari.L, 3);
        func(src, x, y)
    });

    define_lua_func('native_draw_poly2', (func) => {
        let i = 1;
        const mode = fengari.lua.lua_tointeger(fengari.L, 1);
        const verts = [];
        const x = fengari.lua.lua_tonumber(fengari.L, 3);
        const y = fengari.lua.lua_tonumber(fengari.L, 4);
        const scale = fengari.lua.lua_tonumber(fengari.L, 5);
        const angle = fengari.lua.lua_tonumber(fengari.L, 6);
        const ox = fengari.lua.lua_tonumber(fengari.L, 7);
        const oy = fengari.lua.lua_tonumber(fengari.L, 8);
        while (fengari.lua.lua_rawgeti(fengari.L, 2, i) !== fengari.lua.LUA_TNIL) {
            verts.push(fengari.lua.lua_tonumber(fengari.L, -1));
            fengari.lua.lua_pop(fengari.L, 1);
            i++;
        }
        func(mode, verts, x, y, scale, angle, ox, oy)
    });
    
    define_lua_func('native_text_print', (func) => {
        const x = fengari.lua.lua_tonumber(fengari.L, 1);
        const y = fengari.lua.lua_tonumber(fengari.L, 2);
        const text = fengari.to_jsstring(fengari.lua.lua_tostring(fengari.L, 3));
        func(x, y, text);
    });
    
    define_lua_func('native_text_font_size', (func) => {
        const size = fengari.lua.lua_tonumber(fengari.L, 1);
        func(size);
    });
    
    define_lua_func('native_text_font_name', (func) => {
        const name = fengari.to_jsstring(fengari.lua.lua_tostring(fengari.L, 1));
        func(name);
    });
    
    define_lua_func('native_text_font_default', (func) => {
        func();
    });
    
    define_lua_func('native_text_font_previous', (func) => {
        func();
    });
    
    define_lua_func('native_text_mensure', (func) => {
        const text = fengari.to_jsstring(fengari.lua.lua_tostring(fengari.L, 1));
        const [width, height] = func(text);
        fengari.lua.lua_pushnumber(fengari.L, width);
        fengari.lua.lua_pushnumber(fengari.L, height);
        return 2;
    });

    define_lua_func('native_system_get_language', (func) => {
        fengari.lua.lua_pushstring(fengari.L, func());
        return 1;
    });

    define_lua_func('native_media_load', (func) => {
        const channel = fengari.lua.lua_tonumber(fengari.L, 1);
        const src = fengari.to_jsstring(fengari.lua.lua_tostring(fengari.L, 2));
        func(channel, src)
    });

    define_lua_func('native_media_position', (func) => {
        const channel = fengari.lua.lua_tonumber(fengari.L, 1);
        const x = fengari.lua.lua_tonumber(fengari.L, 2);
        const y = fengari.lua.lua_tonumber(fengari.L, 3);
        func(channel, x, y)
    });

    define_lua_func('native_media_resize', (func) => {
        const channel = fengari.lua.lua_tonumber(fengari.L, 1);
        const w = fengari.lua.lua_tonumber(fengari.L, 2);
        const h = fengari.lua.lua_tonumber(fengari.L, 3);
        func(channel, w, h)
    });

    define_lua_func('native_media_time', (func) => {
        const channel = fengari.lua.lua_tonumber(fengari.L, 1);
        const time = fengari.lua.lua_tonumber(fengari.L, 2);
        func(channel, Math.floor(time));
    });

    define_lua_func('native_media_play', (func) => {
        func(fengari.lua.lua_tonumber(fengari.L, 1));
    });

    define_lua_func('native_media_pause', (func) => {
        func(fengari.lua.lua_tonumber(fengari.L, 1));
    });
    
    define_lua_func('native_http_handler', (func) => {
        const request_id = fengari.lua.lua_tonumber(fengari.L, 2);
        func({
            param_dict: {},
            header_dict: {},
            set: (key, value) => httplua(request_id, `set-${key}`, value),
            promise: () => httplua(request_id, 'async-promise'),
            resolve: () => httplua(request_id, 'async-resolve'),
            method: httplua(request_id, 'get-method'),
            body: httplua(request_id, 'get-body'),
            url: httplua(request_id, 'get-fullurl')
        })
    });

    fengari.lua.lua_pushboolean(fengari.L, true)
    fengari.lua.lua_setglobal(fengari.L, fengari.to_luastring('native_http_has_callback'))

    fengari.lua.lua_pushboolean(fengari.L, true)
    fengari.lua.lua_setglobal(fengari.L, fengari.to_luastring('native_http_has_ssl'))

    const json_file = 'jsonrxi.lua'
    const json_response = await fetch(json_file)
    const json_code = (await json_response.text())
        .replace('json.encode', 'native_json_encode')
        .replace('json.decode', 'native_json_decode')
    fengari.lauxlib.luaL_loadbuffer(fengari.L, fengari.to_luastring(json_code), json_code.lenght, json_file);
    fengari.lua.lua_pcall(fengari.L, 0, 0, 0);    

    if (typeof engine_lua === 'string' && !engine_lua.includes('\n')) {
        const engine_response = await fetch(engine_lua)
        engine_lua = await engine_response.text()
    }

    fengari.lauxlib.luaL_loadbuffer(fengari.L, fengari.to_luastring(engine_lua), engine_lua.lenght, 'engine');
    fengari.lua.lua_pcall(fengari.L, 0, 0, 0);

    define_lua_callback('native_callback_init', (width, height, game) => {
        fengari.lua.lua_pushnumber(fengari.L, width);
        fengari.lua.lua_pushnumber(fengari.L, height);
        fengari.lauxlib.luaL_loadbuffer(fengari.L, fengari.to_luastring(game), game.lenght, 'game');
        fengari.lua.lua_pcall(fengari.L, 0, 1, 0);
        return 3;
    })

    define_lua_callback('native_callback_draw')
    define_lua_callback('native_callback_loop', (dt) => {
        fengari.lua.lua_pushnumber(fengari.L, dt);
        return 1;
    })

    define_lua_callback('native_callback_resize', (width, height) => {
        fengari.lua.lua_pushnumber(fengari.L, width);
        fengari.lua.lua_pushnumber(fengari.L, height);
        return 2;
    })

    define_lua_callback('native_callback_keyboard', (key, value) => {
        fengari.lua.lua_pushstring(fengari.L, fengari.to_luastring(key));
        fengari.lua.lua_pushboolean(fengari.L, value);
        return 2;
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
        [13, 'a'],
        [38, 'up'],
        [37, 'left'],
        [40, 'down'],
        [39, 'right'],
        [403, 'a'],
        [404, 'b'],
        [405, 'c'],
        [406, 'd'],
        [10009, 'menu'],
        ['KeyZ', 'a'],
        ['KeyX', 'b'],
        ['KeyC', 'c'],
        ['KeyV', 'd'],
        ['Enter', 'a'],
        ['ArrowUp', 'up'],
        ['ArrowDown', 'down'],
        ['ArrowLeft', 'left'],
        ['ArrowRight', 'right'],
        ['ShiftLeft', 'menu'],
    ];

    function updateSize() {
        gly.resize()
    }

    function updateKey(ev) {
        const key = keys.find(key => [ev.code, ev.keyCode].includes(key[0]))
        if (key) {
            ev.preventDefault()
            gly.input(key[1], ev.type === 'keydown')
        }
    }

    function updateLoop() {
        window.requestAnimationFrame(updateLoop);
        gly.update_uptime(performance.now())
    }

    window.addEventListener('blur', gly.pause)
    window.addEventListener('focus', gly.resume)
    window.addEventListener("resize", updateSize)
    window.addEventListener('keydown', updateKey)
    window.addEventListener('keyup', updateKey)
    window.requestAnimationFrame(updateLoop);
}
