if (!gly) {
    error('gly is not loaded!')
}

gly.bootstrap = async (game_file) => {
    const engine_file = gly.engine.get()
    const engine_response = await fetch(engine_file)
    const engine_lua = await engine_response.text()

    fengari.lualib.luaL_openlibs(fengari.L);

    const define_lua_callback = (func_name, func_decorator) => {
        gly.global.set(func_name, (a, b, c, d, e, f) => {
            fengari.lua.lua_getglobal(fengari.L, fengari.to_luastring(func_name))
            const res = func_decorator(a, b, c, d, e, f) ?? 0;
            if (fengari.lua.lua_pcall(fengari.L, res, 0, 0) !== 0) {
                throw fengari.to_jsstring(fengari.lua.lua_tostring(fengari.L, -1))
            }
        })
    }

    const define_lua_func = (func_name, func_decorator) => {
        const func_native = gly.global.get(func_name);
        fengari.lua.lua_pushcfunction(fengari.L, () => {
            const res = func_decorator(func_native);
            return res ?? 0;
        });
        fengari.lua.lua_setglobal(fengari.L, fengari.to_luastring(name));
    }

    define_lua_func('native_draw_start', (func) => {
        func();
    });
    
    define_lua_func('native_draw_flush', (func) => {
        func();
    });
    
    define_lua_func('native_draw_clear', (func) => {
        const color = lua.lua_tointeger(fengari.L, 1);
        const x = lua.lua_tonumber(fengari.L, 2);
        const y = lua.lua_tonumber(fengari.L, 3);
        const w = lua.lua_tonumber(fengari.L, 4);
        const h = lua.lua_tonumber(fengari.L, 5);
        func(color, x, y, w, h);
    });
    
    define_lua_func('native_draw_color', (func) => {
        const color = lua.lua_tointeger(fengari.L, 1);
        func(color);
    });
    
    define_lua_func('native_draw_rect', (func) => {
        const mode = lua.lua_tointeger(fengari.L, 1);
        const x = lua.lua_tonumber(fengari.L, 2);
        const y = lua.lua_tonumber(fengari.L, 3);
        const w = lua.lua_tonumber(fengari.L, 4);
        const h = lua.lua_tonumber(fengari.L, 5);
        func(mode, x, y, w, h);
    });
    
    define_lua_func('native_draw_line', (func) => {
        const x1 = lua.lua_tonumber(fengari.L, 1);
        const y1 = lua.lua_tonumber(fengari.L, 2);
        const x2 = lua.lua_tonumber(fengari.L, 3);
        const y2 = lua.lua_tonumber(fengari.L, 4);
        func(x1, y1, x2, y2);
    });
    
    define_lua_func('native_draw_image', (func) => {
        //func();
    });
    
    define_lua_func('native_text_print', (func) => {
        const x = lua.lua_tonumber(fengari.L, 1);
        const y = lua.lua_tonumber(fengari.L, 2);
        const text = fengari.to_jsstring(fengari.lua.lua_tostring(fengari.L, 3));
        func(x, y, text);
    });
    
    define_lua_func('native_text_font_size', (func) => {
        const size = lua.lua_tonumber(fengari.L, 1);
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
        lua.lua_pushnumber(fengari.L, width);
        lua.lua_pushnumber(fengari.L, height);
        return 2;
    });

    fengari.lauxlib.luaL_dostring(fengari.L, fengari.to_luastring(engine_lua));

    define_lua_callback('native_callback_init', (width, height, game) => {
        fengari.lua.lua_pushnumber(fengari.L, width);
        fengari.lua.lua_pushnumber(fengari.L, height);
        fengari.lua.lua_pushstring(fengari.L, fengari.to_luastring(game));
        return 3;
    })

    gly.error('stop, canvas, console')
    gly.init('#gameCanvas')

    if (typeof game_file === 'string' && !game_file.includes('\n')) {
        const game_response = await fetch(game_file)
        gly.load(await game_response.text())
    } else {
        gly.load(game_file)
    }
}
