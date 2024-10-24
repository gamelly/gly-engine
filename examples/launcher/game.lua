--! @todo rework

--! @par Game FSM
--! @startuml
--! hide empty description
--! skinparam State {
--!   FontColor white
--! }
--! state 1 as "boot" #sienna
--! state 2 as "download csv" #darkblue
--! state 3 as "parse csv" #darkgreen
--! state 4 as "menu launcher" #gray
--! state 5 as "download game" #blue
--! state 6 as "load game" #green
--! state 7 as "run game" #black
--! state 8 as "exit game" #brown
--! state 9 as "http failed" #orange
--! state 10 as "error" #red
--! 
--! [*] --> 1
--! 1 --> 2
--! 2 --> 3
--! 3 --> 4
--! 4 --> 5
--! 5 --> 6
--! 6 --> 7
--! 7 --> 8
--! 8 --> 4
--! 2 --> 9
--! 5 --> 9
--! 1 -[dotted]-> 10
--! 2 -[dotted]-> 10
--! 3 -[dotted]-> 10
--! 4 -[dotted]-> 10
--! 5 -[dotted]-> 10
--! 6 -[dotted]-> 10
--! 7 -[dotted]-> 10
--! 8 -[dotted]-> 10
--! 10 --> [*]
--! 9 --> [*]
--! @enduml

local function next_state(game, new_state)
    if game._state + 1 == new_state then
        game._state = new_state
    end
    if game._state == 2 and new_state == 9 then
        game._state = new_state
    end
    if game._state == 5 and new_state == 9 then
        game._state = new_state
    end
    if game._state == 8 and new_state == 4 then
        game._state = new_state
    end
end

local function halt_state(game)
    return function (func)
        local ok, message = pcall(func)
        if not ok then
            game._state = 10
            game._error = message
        end
    end
end

local function init(std, game)
    if not game._state then
        game._state = 0
        game._menu = 1
        game._csv = ''
        game._list = {}
        game._source = ''
        game._menu_time = std.milis
        game._want_leave = false
        std.game.exit = function () 
            game._want_leave = true
        end
    end
end

local function http(std, game)
    halt_state(game)(function ()
        if std.http.error then
            error(std.http.error)
        end
        if not std.http.ok then
            next_state(game, 9)
            game._status = std.http.status
            game._error = std.http.body
        end
        if std.http.body and #std.http.body == 0 then
            next_state(game, 9)
            game._status = std.http.status
            game._error = '<empty>'
        end
        if game._state == 2 then
            game._csv = std.http.body
        end
        if game._state == 5 then
            game._source = std.http.body
        end
    end)
end

local function loop(std, game)
    if game._state == 0 then
       next_state(game, 1) 
    elseif game._state == 1 then
        halt_state(game)(function() 
            next_state(game, 2)
            std.http.get('http://t.gamely.com.br/games.json'):run()
        end)
    elseif game._state == 2 and #game._csv > 0 then
        next_state(game, 3)
    elseif game._state == 3 then
        halt_state(game)(function() 
            game._list = std.json.decode(game._csv)
            game._csv = ''
            next_state(game, 4)
        end)
    elseif game._state == 4 then
        halt_state(game)(function() 
            local key = std.key.axis.y
            if key ~= 0 and std.milis > game._menu_time + 250 then
                game._menu = std.math.clamp2(game._menu + key, 1, #game._list)
                game._menu_time = std.milis
            end
            if std.key.press.a and std.milis > game._menu_time + 250 then
                game._menu_time = std.milis
                next_state(game, 5)
                std.http.get(game._list[game._menu].raw_url):run()
            end
        end)
    elseif game._state == 5 and #game._source > 0 then
        next_state(game, 6)
    elseif game._state == 6 then
        halt_state(game)(function()
            std.bus.spawn(std.game.load(game._source))
            std.bus.emit('init')
            game._source = ''
            next_state(game, 7)
        end)
    elseif game._state == 7 then

    elseif game._state == 8 then
        
    end
end

local function draw(std, game)
    if game._state == 1 then
        std.draw.clear(std.color.darkbrown)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, 'booting...')
    elseif game._state == 2 then
        std.draw.clear(std.color.darkblue)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, 'downloading csv...')
    elseif game._state == 3 then
        std.draw.clear(std.color.darkgreen)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, 'parsing csv...')
    elseif game._state == 4 then
        std.draw.clear(0x333333FF)
        std.draw.color(std.color.white)
        std.draw.font('Tiresias', 12)
        local index = 1
        while index <= #game._list do
            std.draw.text(16, 8 + (index * 14), game._list[index].title)
            std.draw.text(200, 8 + (index * 14), game._list[index].version)
            std.draw.text(300, 8 + (index * 14), game._list[index].author)
            index = index + 1
        end
        std.draw.color(std.color.red)
        std.draw.rect(1, 16, 9 + (game._menu * 14), game.width - 32, 16)
    elseif game._state == 5 then
        std.draw.clear(std.color.blue)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, 'download game...')
    elseif game._state == 6 then
        std.draw.clear(std.color.green)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, 'loading game...')
    elseif game._state == 7 then
    elseif game._state == 8 then
        std.draw.clear(std.color.gold)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, 'exiting game...')
    elseif game._state == 9 then
        std.draw.clear(std.color.orange)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, 'HTTP ERROR:')
        std.draw.text(200, 8, game._status)
        std.draw.text(8, 32, game._error)
    elseif game._state == 10 then
        std.draw.clear(std.color.red)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, 'FATAL ERROR:')
        std.draw.text(8, 32, game._error)
    end
end

local P = {
    meta={
        title='Launcher Games',
        description='online multi game list',
        author='Rodrigo Dornelles',
        version='1.0.0'
    },
    config={
        require='http math.random math json'
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        http=http,
        exit=exit
    }
}

return P
