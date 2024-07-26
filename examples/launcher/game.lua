local function init(std, game)
    if game.multi_state == 4 then
        game.application.callbacks.init(std, game)
        return
    end
    local registry = 'gist.githubusercontent.com/RodrigoDornelles/7ee1ac926b76442d6c303c3a291037c4/raw/c3597529459e487eadccd8597fb1dc72e5034096/games.csv'
    game.multi_text = 'booting...'
    game.multi_state = 1
    game.multi_menu = 1
    game.multi_menu_time = game.milis
    game.multi_list = {}
    std.http.get(registry):run()
end

local function http(std, game)
    if std.http.ok and game.multi_state == 1 then
        std.csv(std.http.body, game.multi_list)
        game.multi_state = 2
    elseif std.http.ok and game.multi_state == 3 then 
        game.multi_state = 1
        game.application = load(std.http.body)
        game.application = game.application and game.application()
        if game.application then
            game.multi_state = 4
            std.game.exit = function()
                game.multi_menu_time = game.milis
                game.multi_state = 2
            end
            game.application.callbacks.init(std, game)
            game.menu_time = game.milis
        end
    else
        game.multi_state = 1
        game.multi_text = std.http.body or std.http.error
    end
end

local function loop(std, game)
    if game.multi_state == 2 then
        local key = std.key.press.down - std.key.press.up
        if key ~= 0 and game.milis > game.multi_menu_time + 250 then
            game.multi_menu = std.math.clamp2(game.multi_menu + key, 1, 2)
            game.multi_menu_time = game.milis
        end
        if std.key.press.enter == 1 and game.milis > game.multi_menu_time + 250 then
            game.multi_state = 3
            game.multi_menu_time = game.milis
            std.http.get(game.multi_list[game.multi_menu].raw_url):run()
        end
    elseif game.multi_state == 4 then
        game.application.callbacks.loop(std, game)
    end
end

local function draw(std, game)
    if game.multi_state == 1 then
        std.draw.clear(std.color.red)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, game.multi_text)
    elseif game.multi_state == 3 then
        std.draw.clear(std.color.blue)
        std.draw.color(std.color.white)
        std.draw.text(8, 8, 'loading...')
    elseif game.multi_state == 2 then
        local s = 0
        std.draw.clear(std.color.darkgray)
        std.draw.color(std.color.white)
        local index = 1
        while index <= #game.multi_list do
            std.draw.text(16, 8 + (index * 14), game.multi_list[index].title)
            std.draw.text(100, 8 + (index * 14), game.multi_list[index].version)
            s=std.math.max(std.draw.text(200, 8 + (index * 12), game.multi_list[index].author), s)
            index = index + 1
        end
        std.draw.color(std.color.red)
        std.draw.rect(1, 16, 5 + (game.multi_menu * 16), 200 + s, 14)
    elseif game.multi_state == 4 then
        game.application.callbacks.draw(std, game)
    end
end

local function exit(std, game)
    if game.multi_state == 4 then
        game.application.callbacks.exit(std, game)
    end
end

local P = {
    meta={
        title='Launcher Games',
        description='a online multi game list',
        author='Rodrigo Dornelles',
        version='1.0.0'
    },
    config={
        require='http random math csv'
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
