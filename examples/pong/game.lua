local function init(std, game)
    game.highscore = game.highscore or 0
    game.player_pos = game.height/2
    game.ball_pos_x = game.width/2
    game.ball_pos_y = game.height/2
    game.ball_spd_x = 500
    game.ball_spd_y = 300
    game.score = 0
end

local function loop(std, game)
    -- moves
    game.ball_size = std.math.max(game.width, game.height) / 160
    game.player_size = std.math.min(game.width, game.height) / 8
    game.ball_pos_x = game.ball_pos_x + (game.width * game.ball_spd_x * std.delta)/1000000
    game.ball_pos_y = game.ball_pos_y + (game.height * game.ball_spd_y * std.delta)/1000000
    game.player_pos = std.math.clamp(game.player_pos + (std.key.axis.y * game.ball_size), 0, game.height - game.player_size)  

    -- colisions
    if game.ball_pos_x >= (game.width - game.ball_size) then
        game.ball_spd_x = -std.math.abs(game.ball_spd_x)
    end
    if game.ball_pos_y >= (game.height - game.ball_size) then
        game.ball_spd_y = -std.math.abs(game.ball_spd_y)
    end
    if game.ball_pos_y <= 0 then
        game.ball_spd_y = std.math.abs(game.ball_spd_y)
    end
    if game.ball_pos_x <= 0 then 
        if std.math.clamp(game.ball_pos_y, game.player_pos, game.player_pos + game.player_size) == game.ball_pos_y then
            game.ball_spd_y = game.ball_spd_y + 500 - (std.milis % 1000)
            game.ball_spd_x = std.math.abs(game.ball_spd_x) * 1.1
            game.score = game.score + 1
        else
            std.app.reset()
        end
    end
end

local function draw(std, game)
    std.draw.clear(std.color.black)
    std.draw.color(std.color.white)
    std.draw.rect(0, game.ball_size, game.player_pos, game.ball_size, game.player_size)
    std.draw.rect(0, game.ball_pos_x, game.ball_pos_y, game.ball_size, game.ball_size)
    std.draw.tui_text(20, 1, 2, game.score)
    std.draw.tui_text(60, 1, 2, game.highscore)
end

local function exit(std, game)
    game.highscore = std.math.max(game.highscore, game.score)
end

local P = {
    meta={
        title='Ping Pong',
        author='RodrigoDornelles',
        description='simple pong',
        version='1.0.0'
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        exit=exit
    }
}

return P;
