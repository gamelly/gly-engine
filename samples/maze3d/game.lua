local function wolf_getmap(std, game, x, y)
    local mapX = std.math.floor(x)
    local mapY = std.math.floor(y)
    if mapX < 1 or mapX > game.map.width or mapY < 1 or mapY > game.map.height then
        return 1
    end
    return game.map.grid[(mapY - 1) * game.map.width + mapX]
end

local function wolf_raycast(std, game, angle)
    local dist = 0
    local hit = false
    local hitX, hitY, hitType = nil, nil, 0
    local cosA = std.math.cos(angle)
    local sinA = std.math.sin(angle)
    while (not hit) and (dist < game.max_distance) do
        dist = dist + game.ray_step
        local x = game.player.x + cosA * dist
        local y = game.player.y + sinA * dist
        local cellType = wolf_getmap(std, game, x, y)
        if cellType ~= 0 then
            hit = true
            hitX, hitY = x, y
            hitType = cellType
        end
    end
    return dist, hitX, hitY, hitType
end

local function bot_bfs(std, game, startX, startY, goalX, goalY)
    local queue = {}
    local visited = {}
    local parent = {}
    local dirs = {{dx=1, dy=0}, {dx=-1, dy=0}, {dx=0, dy=1}, {dx=0, dy=-1}}

    queue[#queue+1] = {x=startX, y=startY}
    visited[(startY-1)*game.map.width + startX] = true

    while #queue > 0 do
        local current = table.remove(queue, 1)
        for _, dir in ipairs(dirs) do
            local nx = current.x + dir.dx
            local ny = current.y + dir.dy
            if nx >= 1 and nx <= game.map.width and ny >= 1 and ny <= game.map.height then
                local idx = (ny-1)*game.map.width + nx
                if not visited[idx] and (wolf_getmap(std, game, nx, ny) == 0 or wolf_getmap(std, game, nx, ny) == 2) then
                    visited[idx] = true
                    parent[idx] = current
                    queue[#queue+1] = {x=nx, y=ny}
                    if nx == goalX and ny == goalY then
                        local path = {}
                        local node = {x=nx, y=ny}
                        while node do
                            table.insert(path, 1, node)
                            local p = parent[(node.y-1)*game.map.width + node.x]
                            node = p
                        end
                        return path
                    end
                end
            end
        end
    end
    return nil
end

local function init(std, game)
    game.player = {x=3, y=3, angle=0, fov=std.math.pi/3, speed=5, turn_speed=1.5}
    game.bot = {timer=0, angle=game.player.angle, path=nil, targetIndex=1, state="turning"}
    
    local mapWidth, mapHeight = 20, 20
    local grid = {}
    for y = 1, mapHeight do
        for x = 1, mapWidth do
            grid[(y-1)*mapWidth+x] = (x==1 or x==mapWidth or y==1 or y==mapHeight) and 1 or (math.random()<0.2 and 1 or 0)
        end
    end
    grid[(3-1)*mapWidth+3] = 0
    local finalY = std.math.floor(mapHeight/2)
    grid[(finalY-1)*mapWidth+mapWidth] = 2

    game.map = {width=mapWidth, height=mapHeight, grid=grid}
    game.num_rays = 100
    game.max_distance = 30
    game.ray_step = 0.1
    game.ray_angle_step = game.player.fov / game.num_rays
end

local function bot_move(std, game, dt)
    local goalX, goalY = game.map.width, std.math.floor(game.map.height/2)
    local currentCell = {x=std.math.floor(game.player.x), y=std.math.floor(game.player.y)}

    if currentCell.x == goalX and currentCell.y == goalY then return end

    if not game.bot.path then
        game.bot.path = bot_bfs(std, game, currentCell.x, currentCell.y, goalX, goalY)
        game.bot.targetIndex = 2
        game.bot.state = "turning"
    end

    if not game.bot.path or #game.bot.path < game.bot.targetIndex then return end

    local targetCell = game.bot.path[game.bot.targetIndex]
    if currentCell.x == targetCell.x and currentCell.y == targetCell.y then
        game.bot.targetIndex = game.bot.targetIndex + 1
        game.bot.state = "turning"
        return
    end

    local dx = targetCell.x - currentCell.x
    local dy = targetCell.y - currentCell.y
    local targetAngle = (dx == 1 and 0) or (dx == -1 and std.math.pi) or (dy == 1 and std.math.pi/2) or 3*std.math.pi/2

    game.bot.angle = targetAngle
    local angleDiff = std.math.abs(game.player.angle - targetAngle)
    angleDiff = (angleDiff + std.math.pi) % (2 * std.math.pi) - std.math.pi
    
    if std.math.abs(angleDiff) < 0.1 then
        game.player.x = game.player.x + std.math.cos(game.player.angle) * game.player.speed * dt
        game.player.y = game.player.y + std.math.sin(game.player.angle) * game.player.speed * dt
    end
end

local function loop(std, game)
    game.bot.timer = game.bot.timer + std.delta
    if std.key.press.any then
        game.bot.timer = 0
        game.bot.path = nil
    end

    if game.bot.timer >= 3000 then
        local dt = std.delta / 1000
        local angleDiff = game.bot.angle - game.player.angle
        if std.math.abs(angleDiff) > game.player.turn_speed * dt then
            game.player.angle = game.player.angle + (angleDiff > 0 and game.player.turn_speed or -game.player.turn_speed) * dt
        else
            game.player.angle = game.bot.angle
        end

        bot_move(std, game, dt)
        local cellX, cellY = std.math.floor(game.player.x), std.math.floor(game.player.y)
        if wolf_getmap(std, game, cellX, cellY) == 2 then std.app.reset() end
        return
    end

    local dt = std.delta / 1000
    local speed = game.player.speed * dt
    local new_x = game.player.x + (std.key.press.up and std.math.cos(game.player.angle) or std.key.press.down and -std.math.cos(game.player.angle) or 0) * speed
    local new_y = game.player.y + (std.key.press.up and std.math.sin(game.player.angle) or std.key.press.down and -std.math.sin(game.player.angle) or 0) * speed

    if wolf_getmap(std, game, new_x, game.player.y) == 0 then game.player.x = new_x end
    if wolf_getmap(std, game, game.player.x, new_y) == 0 then game.player.y = new_y end

    if wolf_getmap(std, game, new_x, game.player.y) == 2 or wolf_getmap(std, game, game.player.x, new_y) == 2 then
        std.app.reset()
    end

    if std.key.press.left then game.player.angle = game.player.angle - game.player.turn_speed * dt end
    if std.key.press.right then game.player.angle = game.player.angle + game.player.turn_speed * dt end
end

local function draw(std, game)
    std.draw.clear(0xFFFFFFFF)
    std.draw.color(0xFFA500FF)
    std.draw.rect(0, 0, game.height/2, game.width, game.height/2)

    for i = 0, game.num_rays do
        local angle = game.player.angle - game.player.fov/2 + (i * game.ray_angle_step)
        local dist, _, _, hitType = wolf_raycast(std, game, angle)
        local lineHeight = std.math.min(game.height, 1000 / (dist + 0.0001))
        local x = (i / game.num_rays) * game.width

        local wallColor = hitType == 2 and 0x0000FFFF or (std.math.floor(std.math.max(0.2, 1 - dist/game.max_distance)*255)*0x1000000+0xFF)
        std.draw.color(wallColor)
        std.draw.rect(0, x, (game.height - lineHeight)/2, game.width/game.num_rays + 1, lineHeight)
    end
end

local P = {
    meta = {
        title = 'Maze3D',
        author = 'RodrigoDornelles and AlexOliveira',
        description = 'Raycasting com BFS pathfinding',
        version = '1.0.0'
    },
    config = {
        require = 'math math.random'
    },
    callbacks = {
        init = init,
        loop = loop,
        draw = draw
    }
}

return P
