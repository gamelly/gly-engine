local function init(std, game)
    game.text = 'loading....'
    std.http.get('api.github.com/zen'):header('X-GitHub-Api-Version', '2022-11-28'):run()
end

local function http(std, game)
    game.text = std.http.body or std.http.error
end

local function draw(std, game)
    std.draw.clear(std.color.lightgray)
    std.draw.color(std.color.white)
    std.draw.text(8, 8, game.text)
end

local P = {
    meta={
        title='Github Zen',
        version='1.0.0'
    },
    config={
        require='http'
    },
    callbacks={
        init=init,
        draw=draw,
        http=http
    }
}

return P;
