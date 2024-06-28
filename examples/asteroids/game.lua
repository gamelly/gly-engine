local math = require('math')

local function asteroid_nest(std, game, x, y, id)
    local index = 1
    while index < #game.asteroid_size do
        if index ~= id then
            local distance = game.std.dis(x, y, game.asteroid_pos_x[index], game.asteroid_pos_y[index])
            if distance - 3 <= game.asteroid_size[index] then
                return true
            end
        end
        index = index + 1
    end
    return false
end

local function asteroids_rain(std, game)
    local index = 1
    local n1 = 0.5 * math.min(game.level/3, 1)
    local n2 = 1.0 * math.min(game.level/3, 1)
    local n3 = 2.0 * math.min(game.level/3, 1)
    local n4 = 2.5 * math.min(game.level/3, 1)
    local hspeed = {n1, 0, 0, 0, 0, 0, n1}
    local vspeed = {-n4, -n3, -n2, n2, n3, n4}
    local middle_left = game.width/4
    local middle_right = game.width/4 * 3

    while index <= game.asteroids_max and index <= 10 do
        repeat
            local other = 1
            local success = true
            game.asteroid_size[index] = 11
            game.asteroid_pos_x[index] = love.math.random(1, game.width) -- TODO: use engine random
            game.asteroid_pos_y[index] = love.math.random(1, game.height)
            game.asteroid_spd_x[index] = hspeed[love.math.random(1, #hspeed)]
            game.asteroid_spd_y[index] = vspeed[love.math.random(1, #vspeed)]

            if game.asteroid_pos_x[index] > middle_left and game.asteroid_pos_x[index] < middle_right then
                success = false
            end

            if asteroid_nest(std, game, game.asteroid_pos_x[index], game.asteroid_pos_x[index], index) then
                success = false
            end

            while other < #game.asteroid_size do
                if other ~= index then
                    local distance = game.std.dis(game.asteroid_pos_x[index], game.asteroid_pos_y[index], game.asteroid_pos_x[other], game.asteroid_pos_y[other])
                    if distance <= 11 then
                        success = false
                    end
                end
                other = other + 1
            end
        until success
        index = index + 1
    end
end

local function init(std, game)
    -- game
    game.state = 1
    game.lifes = 3
    game.level = 90
    game.boost = 0.12
    game.speed_max = 5
    game.asteroids_max = 10
    -- player
    game.player_pos_x = game.width/2
    game.player_pos_y = game.height/2
    game.player_spd_x = 0
    game.player_spd_y = 0
    game.player_angle = 0
    game.player_last_teleport = 0
    -- asteroids
    game.asteroid_pos_x = {}
    game.asteroid_pos_y = {}
    game.asteroid_spd_x = {}
    game.asteroid_spd_y = {}
    game.asteroid_size = {}
    asteroids_rain(std, game)
    -- polys
    game.asteroid_large = {4,-5, 4,0, 0,-1, -5,5, 1,8, -2,11, 0,15, 5,17, 11,17, 14,14, 15,12, 17,9, 17,6, 13,-1, 4,-5}
    game.asteroid_mid = {2,0, 0,7, 3,11, 3,16, 8,17, 12,15, 16,14, 12,4, 16,1, 6,0, 2,0}
    game.asteroid_small = {1,0, 0,1, 1,3, 1,4, 0,6, 2,7, 4,7, 6,6, 7,5, 7,1, 4,1, 3,2, 1,0}
    game.asteroid_mini = {2,0, 2,2, 0,2, 0,4, 1,6, 2,6, 2,5, 5,5, 6,3, 4,2, 4,0, 2,0}
    game.spaceship = {-2,3, 0,-2, 2,3}
end

local function loop(std, game)
    -- player move
    game.player_angle = std.math.cycle(game.player_angle + (std.key.press.right - std.key.press.left) * 0.1, math.pi * 2) * math.pi * 2
    game.player_pos_x = game.player_pos_x + (game.player_spd_x/16 * game.dt)
    game.player_pos_y = game.player_pos_y + (game.player_spd_y/16 * game.dt)
    if std.key.press.up == 0 and (std.math.abs(game.player_spd_x) + std.math.abs(game.player_spd_y)) < 0.45 then
        game.player_spd_x = 0
        game.player_spd_y = 0
    end
    if std.key.press.up == 1 then
        game.player_spd_x = game.player_spd_x + (game.boost * math.cos(game.player_angle - math.pi/2))
        game.player_spd_y = game.player_spd_y + (game.boost * math.sin(game.player_angle - math.pi/2))
        local max_spd_x = std.math.abs(game.speed_max * math.cos(game.player_angle - math.pi/2))
        local max_spd_y = std.math.abs(game.speed_max * math.sin(game.player_angle - math.pi/2))
        game.player_spd_x = std.math.clamp(game.player_spd_x, -max_spd_x, max_spd_x) 
        game.player_spd_y = std.math.clamp(game.player_spd_y, -max_spd_y, max_spd_y)
    end
    if game.player_pos_y < 1 then
        game.player_pos_y = game.height
    end
    if game.player_pos_x < 1 then
        game.player_pos_x = game.width
    end
    if game.player_pos_y > game.height then
        game.player_pos_y = 1
    end
    if game.player_pos_x > game.width then
        game.player_pos_x = 1
    end
    -- player teleport
    if std.key.press.down == 1 and game.milis > game.player_last_teleport + 1000 then
        game.player_last_teleport = game.milis
        game.player_spd_x = 0
        game.player_spd_y = 0
        repeat
            game.player_pos_x = love.math.random(1, game.width) -- TODO: use engine random
            game.player_pos_y = love.math.random(1, game.height)
        until not asteroid_nest(std, game, game.player_pos_x, game.player_pos_y, -1)
    end
    -- asteroids move
    local index = 1
    while index < #game.asteroid_size do
        game.asteroid_pos_x[index] = game.asteroid_pos_x[index] + game.asteroid_spd_x[index]
        game.asteroid_pos_y[index] = game.asteroid_pos_y[index] + game.asteroid_spd_y[index]
        if game.asteroid_pos_y[index] < 1 then
            game.asteroid_pos_y[index] = game.height
        end
        if game.asteroid_pos_x[index] < 1 then
            game.asteroid_pos_x[index] = game.width
        end
        if game.asteroid_pos_y[index] > game.height then
            game.asteroid_pos_y[index] = 1
        end
        if game.asteroid_pos_x[index] > game.width then
            game.asteroid_pos_x[index] = 1
        end
        index = index + 1
    end
end

local function draw(std, game)
    std.draw.clear('black')
    -- draw asteroids
    std.draw.color('white')
    local index = 1
    while index < #game.asteroid_size do
        std.draw.poly('fill', game.asteroid_large, game.asteroid_pos_x[index], game.asteroid_pos_y[index], 3)
        index = index + 1
    end
    -- draw player
    std.draw.color('yellow')
    std.draw.poly('fill', game.spaceship, game.player_pos_x, game.player_pos_y, 3, game.player_angle)
end

local function exit(std, game)
    game.asteroid_pos_x = nil
    game.asteroid_pos_y = nil
    game.asteroid_spd_x = nil
    game.asteroid_spd_y = nil
    game.asteroid_size = nil
    game.asteroid_large = nil
    game.asteroid_mid =  nil
    game.asteroid_small = nil
    game.asteroid_mini = nil
end

local P = {
    meta={
        title='AsteroidsTV',
        description='similar to the original but with lasers because televisions may have limited hardware.',
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
