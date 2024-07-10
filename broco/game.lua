--! state 0 as "menu"
--! state 1 as "game"
--! state 2 as "check matches"
--! state 3 as "remove matched"
--! state ? as "pause"

--! 0 --> 1
--! 1 --> 2
--! 2 --> 3
--! 3 --> 1
--! 1 --> ?
--! ? ->> 1

local function init(std, game)
    game.state = 1
    game.switchState = false
    game.difficulty = 3 -- 1 easy, 2 normal, 3 hard
    game.highscore = game.highscore or 0
    game.score = 0

    game.boardStartHorizontal = 200
    game.boardStartVertical   = 120
    game.boardHorSize =  {7, 9, 11}  -- easy, normal, hard
    game.boardVerSize =  {8, 10, 12} -- easy, normal, hard
    game.board = {}

    local maxBrocos
    if game.difficulty == 1 then
        maxBrocos = 4
    elseif game.difficulty == 1 then
        maxBrocos = 5
    else
        maxBrocos = 6
    end
    for cont = 1, (game.boardHorSize[game.difficulty] * game.boardVerSize[game.difficulty]) do
        game.board[cont] = std.math.random(1, maxBrocos)
    end

    game.selected = {}
    game.selected.broco = 0
    game.selected.h = 0
    game.selected.v = 0

    game.playerPos = {}
    game.playerPos.h = 0
    game.playerPos.v = 0

    game.basePoints = 10
    game.brocoMultiplier = {10, 5, 2} -- easy, normal, hard
    game.bingoMultiplier = {5, 3, 1}  -- easy, normal, hard
    game.bingo = 0
    game.matches = 0
    
    game.count = {}
    game.count.squares = 0
    game.count.diamonds = 0
    game.count.triangles = 0
    game.count.plus = 0
    
    game.loopCount = 0
    game.canReadInput = true
end

local function draw_logo(std, game)
    std.draw.font('sans', 100)
    std.draw.color('white')
    std.draw.text(0, 0, 'BROCOS')
end

local function menu_logic(std, game)

end

local function draw_menu(std, game)
    
end

local function loop(std, game)

    --game
    if game.state == 1 then
        if game.canReadInput then
            if std.key.press.right == 1 and game.playerPos.h < (game.boardHorSize[game.difficulty] - 1) then
                game.playerPos.h = game.playerPos.h + 1
                game.canReadInput = false
            end
            if std.key.press.left == 1 and game.playerPos.h > 0 then
                game.playerPos.h = game.playerPos.h - 1
                game.canReadInput = false
            end
            if std.key.press.down == 1 and game.playerPos.v < (game.boardVerSize[game.difficulty] - 1) then
                game.playerPos.v = game.playerPos.v + 1
                game.canReadInput = false
            end
            if std.key.press.up == 1 and game.playerPos.v > 0 then
                game.playerPos.v = game.playerPos.v - 1
                game.canReadInput = false
            end
            if std.key.press.red == 1 then
                local index = 0
                -- if is empty
                if game.selected.broco == 0 then
                    index = (game.playerPos.v * game.boardHorSize[game.difficulty]) + game.playerPos.h + 1
                    game.selected.broco = game.board[index]
                    game.selected.h = game.playerPos.h
                    game.selected.v = game.playerPos.v
                --if is not empty
                else
                    local newSelectedH = game.playerPos.h
                    local newSelectedV = game.playerPos.v

                    local diffH = std.math.abs(game.selected.h - newSelectedH)
                    local diffV = std.math.abs(game.selected.v - newSelectedV)
                    
                    if (diffH + diffV) == 1 then
                        local toSwitch = 0
                        index = (game.playerPos.v * game.boardHorSize[game.difficulty]) + game.playerPos.h + 1
                        toSwitch = game.board[index]
                        if game.selected.broco ~= toSwitch then
                            game.board[index] = game.selected.broco
                            index = (game.selected.v * game.boardHorSize[game.difficulty]) + game.selected.h + 1
                            game.board[index] = toSwitch
                            game.switchState = true
                        end
                    end
                    index = 0
                    game.selected.broco = 0
                    game.selected.h = -1
                    game.selected.v = -1
                end
                game.canReadInput = false
            end
        end
    elseif game.state == 2 then
        local checkPosH = 0
        local checkPosV = 0
        local index = 0
        local limitH = game.boardHorSize[game.difficulty] - 2
        local limitV = game.boardVerSize[game.difficulty] - 2

        game.matches = 0
        game.bingo = 0
        --check rows
        while (checkPosV < game.boardVerSize[game.difficulty]) do
            while (checkPosH < limitH) do
                index = (checkPosV * game.boardHorSize[game.difficulty]) + checkPosH + 1
                game.matches = 0

                if game.board[index] > 0
                and game.board[index] < 7
                and game.board[index] == game.board[index + 1]
                and game.board[index] == game.board[index + 2] then
                    if checkPosH < (limitH - 1) and game.board[index] == game.board[index + 3] then
                        game.matches = game.matches + 1
                        game.board[index + 3] = 7
                        if checkPosH < (limitH - 2) and game.board[index] == game.board[index + 4] then
                            game.matches = game.matches + 1
                            game.board[index + 4] = 7
                        end
                    end

                    game.matches = game.matches + 3
                    game.bingo = game.bingo + 1
                    game.score = game.score + (game.matches * (game.basePoints * game.brocoMultiplier[game.difficulty]))
                    game.score = game.score + (game.bingo * game.bingoMultiplier[game.difficulty])
                    
                    if game.board[index] == 1 then
                        game.count.squares = game.count.squares + game.matches
                    elseif game.board[index] == 2 then
                        game.count.diamonds = game.count.diamonds + game.matches
                    elseif game.board[index] == 3 then
                        game.count.triangles = game.count.triangles + game.matches
                    elseif game.board[index] == 4 then
                        game.count.plus = game.count.plus + game.matches
                    end
                    
                    game.board[index + 2] = 7
                    game.board[index + 1] = 7
                    game.board[index] = 7
                end

                checkPosH = checkPosH + 1
            end
            checkPosH = 0
            checkPosV = checkPosV + 1
        end

        checkPosH = 0
        checkPosV = 0
        --check columns
        while (checkPosH < game.boardHorSize[game.difficulty]) do
            while (checkPosV < limitV) do
                index = (checkPosV * game.boardHorSize[game.difficulty]) + checkPosH + 1
                if game.board[index] > 0
                and game.board[index] < 7
                and game.board[index] == game.board[index + game.boardHorSize[game.difficulty]]
                and game.board[index] == game.board[index + (game.boardHorSize[game.difficulty] * 2)] then
                    if checkPosH < (limitV - 1) and game.board[index] == game.board[index + (game.boardHorSize[game.difficulty] * 3)] then
                        game.matches = game.matches + 1
                        game.board[index + 3] = 8
                        if checkPosH < (limitV - 2) and game.board[index] == game.board[index + (game.boardHorSize[game.difficulty] * 4)] then
                            game.matches = game.matches + 1
                            game.board[index + 4] = 8
                        end
                    end

                    game.matches = game.matches + 3
                    game.bingo = game.bingo + 1
                    game.score = game.score + (game.matches * (game.basePoints * game.brocoMultiplier[game.difficulty]))
                    game.score = game.score + (game.bingo * game.bingoMultiplier[game.difficulty])

                    if game.board[index] == 1 then
                        game.count.squares = game.count.squares + game.matches
                    elseif game.board[index] == 2 then
                        game.count.diamonds = game.count.diamonds + game.matches
                    elseif game.board[index] == 3 then
                        game.count.triangles = game.count.triangles + game.matches
                    elseif game.board[index] == 4 then
                        game.count.plus = game.count.plus + game.matches
                    end
                    
                    game.board[index + (game.boardHorSize[game.difficulty] * 2)] = 8
                    game.board[index + game.boardHorSize[game.difficulty]] = 8
                    game.board[index] = 8
                end
                checkPosV = checkPosV + 1
            end
            checkPosV = 0
            checkPosH = checkPosH + 1
        end
        game.switchState = true
    elseif game.state == 3 then
        local maxBrocos
        if game.difficulty == 1 then
            maxBrocos = 4
        elseif game.difficulty == 1 then
            maxBrocos = 5
        else
            maxBrocos = 6
        end
        for cont = 1, (game.boardHorSize[game.difficulty] * game.boardVerSize[game.difficulty]) do
            if game.board[cont] >= 7 then
                game.board[cont] = std.math.random(1, maxBrocos)
            end
        end
        game.switchState = true
    end
    if game.switchState then
        if game.state == 1 then
            game.state = 2
        elseif game.state == 2 then
            if game.bingo > 0 then
                game.state = 3
            else
                game.state = 1
            end
        elseif game.state == 3 then
            game.state = 1
        end
        game.switchState = false
    end
    if game.loopCount <= 60 then
        game.loopCount = game.loopCount + 1
    else
        game.loopCount = 1
    end
    if (game.loopCount % 10) == 0 and game.canReadInput == false then
        game.canReadInput = true
    end
end

local function renderBroco(std, game, posX, posY, broco)
    if broco == 1 then -- square
        std.draw.colorRgb(225, 215, 0) -- Gold #FFD700
        --std.draw.color('yellow')
        std.draw.rect('fill', posX + 2, posY + 2, 36, 36)
    elseif broco == 2 then -- diamond
        local triangleUp =   {posX+2, posY+15, posX+30, posY+15, posX+16, posY+2}
        local triangleDown = {posX+2, posY+15, posX+30, posY+15, posX+16, posY+30}
        --local diamond = {posX+2, posY+15, posX+30, posY+15, posX+16, posY+2, posX+2, posY+15, posX+30, posY+15, posX+16, posY+30}
        std.draw.colorRgb(185, 242, 255) -- Diamond #B9F2FF
        --std.draw.color('white')
        std.draw.poly('fill', triangleUp)
        std.draw.poly('fill', triangleDown)
        --std.draw.poly('fill', diamond)
    elseif broco == 3 then -- triangle
        local triangle = {posX+2, posY+30, posX+30, posY+30, posX+16, posY+2}
        std.draw.colorRgb(0, 208, 98) -- Emerald #00D062
        --std.draw.color('green')
        std.draw.poly('fill', triangle)
    elseif broco == 4 then -- plus
        std.draw.colorRgb(61, 53, 75) -- Obsidian #3D354B
        --std.draw.color('red')
        std.draw.rect('fill', posX+2, posY+10, 28, 12)
        std.draw.rect('fill', posX+10, posY+2, 12, 28)
    elseif broco == 5 then -- future use
        std.draw.color('red')
        std.draw.rect('fill', posX + 2, posY + 2, 28, 28)
    elseif broco == 6 then -- future use
        std.draw.color('green')
        std.draw.rect('fill', posX + 2, posY + 2, 28, 28)
    elseif broco == 7 then -- diamond, row/horizontal match
        std.draw.color('black')
        std.draw.rect('fill', posX + 2, posY + 2, 28, 28)
    elseif broco == 8 then -- diamond, column/vertical match
        std.draw.color('black')
        std.draw.rect('fill', posX + 2, posY + 2, 28, 28)
    end
end

local function draw(std, game)
    local startH = 0
    local startV = 0

    --draw_logo(std, game)

    if game.state == 0 then
        draw_menu(std, game)
    else 
        -- fill background
        std.draw.colorRgb(66, 66, 66)
        std.draw.rect('fill', 0, 0, game.width, game.height)
        --std.draw.clear('black')

        -- draw highscore
        startH = 40
        startV = 120
        std.draw.colorRgb(192, 192, 192)
        --std.draw.color('white')
        std.draw.rect('fill', startH , startV, 120, 80)
        std.draw.color('black')
        std.draw.text(startH, startV, 'HI-SCORE')
        std.draw.text(startH, startV + 40, string.format("%07d", game.highscore))

        -- draw broco count
        startH = 40
        startV = 280
        std.draw.colorRgb(192, 192, 192)
        --std.draw.color('white')
        std.draw.rect('fill', startH, startV, 120, 280)
        std.draw.color('black')
        std.draw.text(startH, startV, 'BROCO COUNT')

        renderBroco(std, game, startH, startV + 40, 1) --square
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 40, string.format("%05d", game.count.squares))

        renderBroco(std, game, startH, startV + 80, 2) --diamond
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 80, string.format("%05d", game.count.diamonds))

        renderBroco(std, game, startH, startV + 120, 3) --triangle
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 120, string.format("%05d", game.count.triangles))

        renderBroco(std, game, startH, startV + 160, 4) --plus
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 160, string.format("%05d", game.count.plus))

        renderBroco(std, game, startH, startV + 200, 5) --square
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 200, string.format("%05d", game.count.squares))

        renderBroco(std, game, startH, startV + 240, 6) --square
        std.draw.color('black')
        std.draw.text(startH + 40, startV + 240, string.format("%05d", game.count.squares))

        -- draw board background
        startH = game.boardStartHorizontal
        startV = game.boardStartVertical

        std.draw.colorRgb(192, 192, 192)
        std.draw.rect('fill', startH, startV, (game.boardHorSize[game.difficulty] * 40), (game.boardVerSize[game.difficulty] * 40))

        -- draw brocos
        local hor = 0
        local ver = 0
        local posH = 0
        local posV = 0
        for i = 1, (game.boardHorSize[game.difficulty] * game.boardVerSize[game.difficulty]) do
            posH = game.boardStartHorizontal + (hor * 40)
            posV = game.boardStartVertical + (ver * 40)
            
            renderBroco(std, game, posH, posV, game.board[i])
            
            hor = hor + 1
            if(hor >= game.boardHorSize[game.difficulty]) then
                hor = 0
                ver = ver + 1
            end
        end

        -- draw selected broco
        startH = 680
        startV = 120
        std.draw.colorRgb(192, 192, 192)
        --std.draw.color('white')
        std.draw.rect('fill', startH, startV, 120, 160)
        std.draw.color('black')
        std.draw.text(startH, startV, 'SELECTED')
        if game.selected.broco > 0 then
            renderBroco(std, game, startH+40, startV + 80, game.selected.broco)
            startH = game.boardStartHorizontal + (game.selected.h * 40)
            startV = game.boardStartVertical + (game.selected.v * 40)
            std.draw.color('black')
            std.draw.rect('line', startH, startV, 40, 40)
        end

        startH = 680
        startV = 320
        -- draw score
        std.draw.colorRgb(192, 192, 192)
        --std.draw.color('white')
        std.draw.rect('fill', startH , startV, 96, 64)
        std.draw.color('black')
        std.draw.text(startH, startV, '  SCORE')
        std.draw.text(startH, startV + 40, string.format("%07d", game.score))
        
        -- draw player
        startH = game.boardStartHorizontal + (game.playerPos.h * 40)
        startV = game.boardStartVertical + (game.playerPos.v * 40)
        std.draw.color('black')
        std.draw.rect('line', startH, startV, 40, 40)
        
    end
end

local function exit(std, game)
    game.highscore = std.math.clamp(game.highscore, game.score, game.highscore)
end

local P = {
    meta={
        title='Brocos',
        description='brocos',
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