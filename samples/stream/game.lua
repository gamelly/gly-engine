local function init(std, data)
    data.menu = 1
    data.msg = 'loading...'
    data.time = std.milis
    data.wmax = 1
    std.http.get('http://t.gamely.com.br/medias.json'):json()
        :error(function()
            data.msg = std.http.error
        end)
        :failed(function()
            data.msg = tostring(std.http.status)
        end)
        :success(function()
            data.list = std.http.body
            data.msg = nil
        end)
        :run()
end

local function loop(std, data)
    if not data.list or #data.list == 0 then return end
    if data.time + 300 < std.milis and std.key.press.any then
        data.menu = std.math.clamp2(data.menu + std.key.axis.y, 1, #data.list)
        data.time = std.milis
        if std.key.press.a then
            std.media.video():src(data.list[data.menu]):play()
        end
        if std.key.press.b then
            std.media.video():resume()
        end
        if std.key.press.c then
            std.media.video():pause()
        end
        if std.key.press.d then
            std.media.video():stop()
        end
        if std.key.press.left then
            std.media.video():resize(640, 320)
        end
        if std.key.press.right then
            std.media.video():resize(data.width, data.height)
        end
    end
end

local function draw(std, data)
    if data.msg then
        std.text.put(1, 1, data.msg)
    end
    if data.list and #data.list > 0 then
        local font_size = 12
        local w, h = data.width/6, data.height/4
        local w2, h2, index = data.width - data.wmax, h*2, 1
        local h3 = (#data.list + 1) * font_size
        std.draw.color(std.color.blue)
        std.draw.rect(0, w2 - 16, h, data.wmax + 32, h3 + font_size)
        std.draw.color(std.color.skyblue)
        std.text.font_size(font_size)
        std.draw.rect(0, w2 - 16, (data.menu * font_size) + h, data.wmax + 16, font_size)
        std.draw.color(std.color.white)
        std.draw.rect(1, w2 - 16, h, data.wmax + 32, h3 + font_size)
        while index <= #data.list do
            data.wmax = std.math.max(data.wmax, std.text.print_ex(data.width - 8, (index * font_size) + h, data.list[index], -1))
            index = index + 1
        end
    end
end

local function exit(std, data)
end

local P = {
    meta={
        title='Streamming',
        description='play videos online!',
        author='Rodrigo Dornelles',
        version='1.0.0'
    },
    config={
        require='http json media.video'
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        exit=exit
    }
}

return P
