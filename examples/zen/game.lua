local function init(std, game)
    game.text = 'loading....'
    std.http.get('api.github.com/zen')
        :header('X-GitHub-Api-Version', '2022-11-28')
        :success(function()
            game.text = std.http.body
        end)
        :run()
end

local function draw(std, game)
    std.draw.clear(std.color.lightgray)
    std.draw.color(std.color.white)
    std.draw.text(8, 8, game.text)
end

local P = {
    meta={
        title='Github Zen',
    },
    config={
        require='http'
    },
    callbacks={
        init=init,
        draw=draw,
        loop=function() end,
        exit=function() end
    }
}

return P;
