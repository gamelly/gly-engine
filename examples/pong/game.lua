local function init(std, game)
    game.highscore = game.highscore or 0
    game.player_size = game.height/8
    game.player_pos = game.height/2 - game.player_size/2
    game.ball_pos_x = game.witdh/2
    game.ball_pos_y = game.height/2
    game.ball_spd_x = 5
    game.ball_spd_y = 1
    game.ball_size = 8
    game.score = 0
end

local function loop(std, game)
    -- inputs
    game.player_dir = std.key.press.down - std.key.press.up
    -- moves
    game.player_pos = std.math.clamp(game.player_pos + (game.player_dir * 7), 0, game.height - game.player_size)
    game.ball_pos_x = game.ball_pos_x + game.ball_spd_x
    game.ball_pos_y = game.ball_pos_y + game.ball_spd_y
    -- colisions
    if game.ball_pos_x >= (game.witdh - game.ball_size) then
        game.ball_spd_x = game.ball_spd_x * -1
    end
    if game.ball_pos_y <= 0 or game.ball_pos_y >= (game.height - game.ball_size) then
        game.ball_spd_y = game.ball_spd_y * -1
    end
    if game.ball_pos_x <= 0 then 
        if std.math.clamp(game.ball_pos_y, game.player_pos, game.player_pos + game.player_size) == game.ball_pos_y then
            game.ball_spd_y = std.math.clamp(game.ball_spd_y + (game.player_pos % 10) - 5, -10, 10)
            game.ball_spd_x = game.ball_spd_x * -1.05
            game.score = game.score + 1
        else
            std.game.reset()
        end
    end
end

local function draw(std, game)
    std.draw.color('black')
    std.draw.rect('fill', 0, 0, game.witdh, game.height)
    std.draw.color('white')
    std.draw.rect('fill', 4, game.player_pos, 8, game.player_size)
    std.draw.rect('fill', game.ball_pos_x, game.ball_pos_y, game.ball_size, game.ball_size)
    std.draw.font('Tiresias', 32)
    std.draw.text(game.witdh/4, 16, game.score)
    std.draw.text(game.witdh/4 * 3, 16, game.highscore)
end

local function exit(std, game)
    game.highscore = std.math.clamp(game.highscore, game.score, game.highscore)
end

local P = {
    meta={
        title='Pong',
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
