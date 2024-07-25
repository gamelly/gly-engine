--! @cond
local fixture190 = ''
local application = nil
local canvas = nil
local event = nil
local ginga = nil
local game = nil
local std = nil
--! @endcond

-- key mappings
local key_bindings={
    CURSOR_UP='up',
    CURSOR_DOWN='down',
    CURSOR_LEFT='left',
    CURSOR_RIGHT='right',
    RED='red',
    GREEN='green',
    YELLOW='yellow',
    BLUE='blue',
    F6='red',
    z='red',
    x='green',
    c='yellow',
    v='blue',
    ENTER='enter'
}

-- FPS
local fps_obj = {total=0,count=0,period=0,passed=0,delta=0,falls=0,drop=0}
local fps_limiter = {[100]=1, [60]=10, [30]=30, [20]=40, [15]=60, [10]=90}
local fps_dropper = {[100]=60, [60]=30, [30]=20, [20]=15, [15]=10, [10]=10}

local function event_loop(evt)
    if evt.class ~= 'key' then return end
    if not key_bindings[evt.key] then return end

    --! @li https://github.com/TeleMidia/ginga/issues/190
    if #fixture190 == 0 and evt.key ~= 'ENTER' then
        fixture190 = evt.type
    end

    if fixture190 == evt.type then
        std.key.press[key_bindings[evt.key]] = 1
    else
        std.key.press[key_bindings[evt.key]] = 0
    end
end

local function fixed_loop()
    -- internal clock 
    game.milis = event.uptime()
    game.fps = fps_obj.total
    game.dt = fps_obj.delta 
    if not application.internal.fps_counter(game.fps_max, fps_obj, game.milis) then
        game.fps_max = fps_dropper[game.fps_max]
    end

    -- game loop
    application.callbacks.loop(std, game)
    
    -- game render
    canvas:attrColor(0, 0, 0, 0)
    canvas:clear()
    application.callbacks.draw(std, game)
    if game.fps_show and game.fps_show >= 0 and std.draw.fps then
        std.draw.fps(game.fps_show, 8, 8)
    end
    canvas:flush()

    -- internal loop
    event.timer(fps_limiter[game.fps_max], fixed_loop)
end

local function install(lstd, lgame, lapplication, ginga)
    fps_obj.drop_time = lapplication.config and lapplication.config.fps_time or 1
    fps_obj.drop_count = lapplication.config and lapplication.config.fps_drop or 2
    application=lapplication
    event=ginga.event
    canvas=ginga.canvas
    game=lgame
    std=lstd
    event.register(event_loop)
    event.timer(1, fixed_loop)
end

local P = {
    install=install
}

return P
