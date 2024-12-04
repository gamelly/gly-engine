local function draw_logo(std, game, height, anim)
    anim = anim or 0
    std.text.font_size(32)
    std.draw.color(std.color.white)
    local s1 = std.text.mensure('CapyBird')
    std.text.print(game.width/2 - s1/2, height + anim, 'Capy')
    std.draw.color(std.color.yellow)
    std.text.print(game.width/2 + s1/2 - std.text.mensure('Bird'), height - anim, 'Birdy')
    return s1
end

local function check_collision(std, game, bird_x, bird_y, pipe_x, pipe_y, pipe_gap)
    local bird_size = 20  -- Bird size
    local pipe_width = 50  -- Pipe width
    local pipe_height = game.height  -- Full pipe height
    
    -- Check horizontal collision
    if bird_x + bird_size > pipe_x and bird_x < pipe_x + pipe_width then
        -- Check vertical collision with top pipe
        if bird_y < pipe_y or 
           -- Check vertical collision with bottom pipe
           bird_y + bird_size > pipe_y + pipe_gap then
            return true
        end
    end
    
    return false
end

local function init(std, game)
    -- Reset game state completely
    game.state = 2  -- Start directly in playing state
    game.score = 0
    
    -- Bird properties
    game.bird_y = game.height / 2
    game.bird_velocity = 0
    game.bird_gravity = 0.5
    game.bird_jump_strength = -7
    
    -- Pipe properties
    game.pipes = {}
    game.pipe_gap = 200  -- Gap between top and bottom pipes
    game.pipe_width = 50
    game.pipe_spawn_timer = 0
    game.pipe_spawn_interval = 1500  -- milliseconds between pipe spawns
    
    -- Menu
    game.menu = 2
    game.menu_time = 0

    
end

local function spawn_pipe(std, game)
    local pipe_height = std.math.random(100, game.height - game.pipe_gap - 100)
    table.insert(game.pipes, {
        x = game.width,
        y = pipe_height,
        passed = false
    })
end

local function loop(std, game)
    if game.state == 1 then
        -- Menu navigation
        local keyh = std.key.axis.x + std.key.axis.a 
        if std.key.axis.y ~= 0 and std.milis > game.menu_time + 250 then
            game.menu = std.math.clamp(game.menu + std.key.axis.y, 2, 4)
            game.menu_time = std.milis
        end
        
        if keyh ~= 0 and std.milis > game.menu_time + 100 then
            game.menu_time = std.milis
            if game.menu == 2 then
                init(std, game)  -- reset stats
            elseif game.menu == 3 then
                -- nothing for now
            elseif game.menu == 4 then
                std.app.exit()
            end
        end
        return
    end
    
    if game.state == 2 then
        -- Bird physics
        game.bird_velocity = game.bird_velocity + game.bird_gravity
        game.bird_y = game.bird_y + game.bird_velocity
        
        -- Jump mechanic
        if std.key.press.a then
            game.bird_velocity = game.bird_jump_strength
        end
        
        -- Spawn pipes
        game.pipe_spawn_timer = game.pipe_spawn_timer + std.delta
        if game.pipe_spawn_timer >= game.pipe_spawn_interval then
            spawn_pipe(std, game)
            game.pipe_spawn_timer = 0
        end
        
        -- Move pipes
        for i = #game.pipes, 1, -1 do
            game.pipes[i].x = game.pipes[i].x - 3
            
            -- Check scoring
            if not game.pipes[i].passed and game.pipes[i].x < game.width/2 then
                game.score = game.score + 1
                game.pipes[i].passed = true
            end
            
            -- Remove off-screen pipes
            if game.pipes[i].x < -game.pipe_width then
                table.remove(game.pipes, i)
            end
            
            -- Collision detection
            if check_collision(std, game, game.width/4, game.bird_y, 
                               game.pipes[i].x, game.pipes[i].y, game.pipe_gap) then
                game.state = 3  -- Game over
                game.menu_time = std.milis
            end
        end
        
        -- botton and top collision
        if game.bird_y > game.height - 20 or game.bird_y < 0 then
            game.state = 3  -- Game over
            game.menu_time = std.milis
        end
    end
    
    -- Game over state
    if game.state == 3 and std.milis > game.menu_time + 2000 then
        game.state = 1
        game.highscore = std.math.max(game.score, game.highscore or 0)
    end
end

local function draw(std, game)
    std.draw.clear(std.color.skyblue)
    
    if game.state == 1 then
        local h = game.height/16
        local hmenu = (h*(4+game.menu)) + 24
        
        local s = draw_logo(std, game, h*2)
        std.text.font_size(16)
        std.draw.color(std.color.white)
        
        std.text.print(game.width/2 - s, h*6, 'New Game')
        std.text.print(game.width/2 - s, h*7, 'Settings')
        std.text.print(game.width/2 - s, h*8, 'Exit')
        
        std.draw.line(game.width/2 - s, hmenu, game.width/2 + s, hmenu)
        
        -- High score display
        std.text.print_ex(game.width/2, h*10, 'High Score: ' .. (game.highscore or 0), 0)
        return
    end
    
    if game.state == 2 or game.state == 3 then
        -- Draw pipes
        std.draw.color(std.color.green)
        for _, pipe in ipairs(game.pipes) do
            -- Top pipe
            std.draw.rect(0, pipe.x, 0, game.pipe_width, pipe.y)
            -- Bottom pipe
            std.draw.rect(0, pipe.x, pipe.y + game.pipe_gap, game.pipe_width, game.height - pipe.y - game.pipe_gap)
        end
        
        -- Draw bird
        std.draw.color(std.color.beige)
        std.draw.rect(0, game.width/4, game.bird_y, 20, 20)
        std.draw.color(std.color.darkbrown)
        std.draw.rect(1, game.width/4, game.bird_y, 20, 20)
        
        -- Score display
        std.draw.color(std.color.yellow)
        std.text.font_size(16)
        std.text.print_ex(game.width - 100, 20, 'Score: ' .. game.score, 0)
    end
    
    -- Game over screen
    if game.state == 3 then
        std.draw.color(std.color.black)
        std.text.font_size(32)
        std.text.print_ex(game.width/2, game.height/2, 'Game Over', 0)
    end
end

local function exit(std, game)
    game.highscore = std.math.max(game.score, game.highscore or 0)
    game.pipes = nil
end

local P = {
    meta={
        title='CapyBird',
        author='Alex Oliveira',
        description='A simple Flappy Bird clone',
        version='1.0.0'
    },
    config = {
        require = 'math math.random',
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        exit=exit
    }
}

return P
