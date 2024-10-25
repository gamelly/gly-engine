local function load(std, data)
    data._menu = 1
    std.http.get('http://t.gamely.com.br/games.json')
        :success(function()
            data._list = std.json.decode(std.http.body)
        end)
        :run()
end

local function keys(std, data)
    if data._game then return end
    if not data._list then return end

    data._menu = std.math.clamp2(data._menu + std.key.axis.y, 1, #data._list)

    if std.key.press.a then
        data._game = {}
        std.http.get(data._list[data._menu].raw_url)
            :success(function()
                data._game = std.node.load(std.http.body)
                std.node.spawn(data._game)
                std.bus.emit('init')
                std.bus.emit('i18n')
            end)
            :run()
    end
end

local function draw(std, data)
    if data._game then return end
    std.draw.clear(0x333333FF)
    std.draw.color(std.color.white)
    if not data._list then 
        std.draw.tui_text(10, 10, 10, 'loading...')
        return
    end
    local index = 1
    std.draw.font(12)
    while index <= #data._list do
        std.draw.text(16, 8 + (index * 14), data._list[index].title)
        std.draw.text(200, 8 + (index * 14), data._list[index].version)
        std.draw.text(300, 8 + (index * 14), data._list[index].author)
        index = index + 1
    end
    std.draw.color(std.color.red)
    std.draw.rect(1, 16, 9 + (data._menu * 14), data.width - 32, 16)
end

local function quit(std, data)
    std.bus.abort()
    std.node.kill(data._game)
    data._game = nil
end

local P = {
    meta={
        title='Launcher Games',
        description='online multi game list',
        author='Rodrigo Dornelles',
        version='1.0.0'
    },
    config={
        require='http math.random math json i18n'
    },
    callbacks={
        load=load,
        key=keys,
        draw=draw,
        quit=quit
    }
}

return P
