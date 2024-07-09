--! state 1 as "game"
--! state 2 as "check matches"
--! state 3 as "remove matched"

--! 1 --> 2
--! 2 --> 3
--! 3 --> 1

local function init(std, game)
    game.state = 1
    game.switchState = false
    --game.boardStartX = game.height / 4
    --game.boardStartY = game.width / 8
    game.boardStartX = 100
    game.boardStartY = 100
    game.boardColumns = 10
    game.boardRows = 12
    game.board = {}
    for cont = 1, (game.boardColumns * game.boardRows) do
        game.board[cont] = std.math.random(1,4)
    end
    game.playerPosX = 0
    game.playerPosY = 0
    game.score = 0
    game.brocoMultiplier = 10
    game.bingoMultiplier = 1
    game.highscore = game.highscore or 0
    game.selected = 0
    game.selectedRow = 0
    game.selectedColumn = 0
    std.draw.font('Tiresias', 32)
    game.loopCount = 0
    game.canReadInput = true
    game.countSquares = 0
    game.countDiamonds = 0
    game.countTriangles = 0
    game.countPlus = 0
    game.bingo = 0
    game.matches = 0
end

local function loop(std, game)
    -- game
    if game.state == 1 then
        ---- inputs
        if game.canReadInput then
            -- move right
            if std.key.press.right == 1 and game.playerPosX < (game.boardColumns - 1) then
                game.playerPosX = game.playerPosX + 1
            end
            -- move left
            if std.key.press.left == 1 and game.playerPosX > 0 then
                game.playerPosX = game.playerPosX - 1
            end
            -- move down
            if std.key.press.down == 1 and game.playerPosY < (game.boardRows - 1) then
                game.playerPosY = game.playerPosY + 1
            end
            -- move up
            if std.key.press.up == 1 and game.playerPosY > 0 then
                game.playerPosY = game.playerPosY - 1
            end
            -- select broco
            if std.key.press.red == 1 then
                local index = 0
                -- if is empty
                if game.selected == 0 and index == 0 then
                    index = (game.playerPosY * game.boardColumns) + game.playerPosX + 1
                    game.selected = game.board[index]
                    game.selectedColumn = game.playerPosX
                    game.selectedRow = game.playerPosY
                --if is not empty
                else
                    local newSelectedColumn = game.playerPosX
                    local newSelectedRow = game.playerPosY

                    local diffX = std.math.abs(game.selectedColumn - newSelectedColumn)
                    local diffY = std.math.abs(game.selectedRow - newSelectedRow)
                    
                    if (diffX + diffY) == 1 then
                        local toSwitch = 0
                        index = (game.playerPosY * game.boardColumns) + game.playerPosX + 1
                        toSwitch = game.board[index]
                        if game.selected ~= toSwitch then
                            game.board[index] = game.selected
                            index = (game.selectedRow * game.boardColumns) + game.selectedColumn + 1
                            game.board[index] = toSwitch
                            game.switchState = true
                        end
                    end
                    index = 0
                    game.selected = 0
                    game.selectedColumn = -1
                    game.selectedRow = -1
                end
            end
            game.canReadInput = false
        end
    --check matches
    elseif game.state == 2 then
        local checkPosX = 0
        local checkPosY = 0
        local index = 0

        --check rows
        local matches = 0
        local bingo = 0
        game.matches = 0
        game.bingo = 0
        while (checkPosY < game.boardRows) do
            while (checkPosX <= 7) do
                index = (checkPosY * game.boardColumns) + checkPosX + 1
                matches = 0
                if game.board[index] > 0
                and game.board[index] < 5
                and game.board[index] == game.board[index+1]
                and game.board[index] == game.board[index+2] then
                    if checkPosX < 7 and game.board[index] == game.board[index+3] then
                        matches = matches + 1
                        game.board[index+3] = 5
                        if checkPosX < 6 and game.board[index] == game.board[index+4] then
                            matches = matches + 1
                            game.board[index+4] = 5
                        end
                    end
                    
                    matches = matches + 3
                    game.matches = game.matches + matches
                    bingo = bingo + 1
                    game.bingo = game.bingo + bingo
                    game.score = game.score + (matches * game.brocoMultiplier)  -- 10 points per broco
                    game.score = game.score + (bingo * game.bingoMultiplier)    -- cumulative extra points

                    if game.board[index] == 1 then
                        game.countSquares = game.countSquares + matches
                    elseif game.board[index] == 2 then
                        game.countDiamonds = game.countDiamonds + matches
                    elseif game.board[index] == 3 then
                        game.countTriangles = game.countTriangles + matches
                    elseif game.board[index] == 4 then
                        game.countPlus = game.countPlus + matches
                    end

                    game.board[index+2] = 5
                    game.board[index+1] = 5
                    game.board[index] = 5
                end
                checkPosX = checkPosX + 1
            end
            checkPosX = 0
            checkPosY = checkPosY + 1
        end

        checkPosX = 0
        checkPosY = 0
        while (checkPosX < game.boardColumns) do
            while (checkPosY < (game.boardRows - 2)) do
                index = (checkPosY * game.boardColumns) + checkPosX + 1
                matches = 0
                if game.board[index] > 0
                and game.board[index] < 5
                and game.board[index] == game.board[index+game.boardColumns]
                and game.board[index] == game.board[index+(game.boardColumns * 2)] then
                    if checkPosY < 9 and game.board[index] == game.board[index+(game.boardColumns * 3)] then
                        matches = matches + 1
                        game.board[index+(game.boardColumns * 3)] = 6
                        if checkPosY < 8 and game.board[index] == game.board[index+(game.boardColumns * 4)] then
                            matches = matches + 1
                            game.board[index+(game.boardColumns * 4)] = 6
                        end
                    end

                    matches = matches + 3
                    game.matches = game.matches + matches
                    bingo = bingo + 1
                    game.bingo = game.bingo + bingo
                    game.score = game.score + (matches * game.brocoMultiplier)  -- 10 points per broco
                    game.score = game.score + (bingo * game.bingoMultiplier)    -- cumulative extra points

                    if game.board[index] == 1 then
                        game.countSquares = game.countSquares + matches
                    elseif game.board[index] == 2 then
                        game.countDiamonds = game.countDiamonds + matches
                    elseif game.board[index] == 3 then
                        game.countTriangles = game.countTriangles + matches
                    elseif game.board[index] == 4 then
                        game.countPlus = game.countPlus + matches
                    end

                    game.board[index+(game.boardColumns * 2)] = 6
                    game.board[index+game.boardColumns] = 6
                    game.board[index] = 6
                end
                checkPosY = checkPosY + 1
            end
            checkPosY = 0
            checkPosX = checkPosX + 1
        end
        game.switchState = true
    -- generate new brocos
    elseif game.state == 3 then
        for i = 1, (game.boardColumns * game.boardRows) do
            if game.board[i] == 5 or game.board[i] == 6 then
                game.board[i] = std.math.random(1,4)
            end
        end
        game.switchState = true
    end
    if game.switchState then
        if game.state == 1 then
            game.state = 2
        elseif game.state == 2 then
            game.state = 3
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
        --std.draw.colorRgb(225, 215, 0) -- Gold #FFD700
        std.draw.color('yellow')
        std.draw.rect('fill', posX + 2, posY + 2, 28, 28)
    elseif broco == 2 then -- diamond
        --local triangleUp =   {posX+2, posY+15, posX+30, posY+15, posX+16, posY+2}
        --local triangleDown = {posX+2, posY+15, posX+30, posY+15, posX+16, posY+30}
        local diamond = {posX+2, posY+15, posX+30, posY+15, posX+16, posY+2, posX+2, posY+15, posX+30, posY+15, posX+16, posY+30}
        --std.draw.colorRgb(185, 242, 255) -- Diamond #B9F2FF
        std.draw.color('white')
        --std.draw.circle('fill', (posX + 16), (posY + 16), 28)
        --std.draw.poly('fill', triangleUp)
        --std.draw.poly('fill', triangleDown)
        std.draw.poly('fill', diamond)
    elseif broco == 3 then -- triangle
        local triangle = {posX+2, posY+30, posX+30, posY+30, posX+16, posY+2}
        --std.draw.colorRgb(64, 224, 208) -- Turquoise #40E0D0
        std.draw.color('green')
        std.draw.poly('fill', triangle)
    elseif broco == 4 then -- plus
        --std.draw.colorRgb(61, 53, 75) -- Obsidian #3D354B
        std.draw.color('red')
        std.draw.rect('fill', posX+2, posY+10, 28, 12)
        std.draw.rect('fill', posX+10, posY+2, 12, 28)
    elseif broco == 5 then -- diamond, row/horizontal match 
        std.draw.color('black')
        --std.draw.circle('fill', (posX + 16), (posY + 16), 28)
        std.draw.rect('fill', posX + 2, posY + 2, 28, 28)
    elseif broco == 6 then -- diamond, column/vertical match
        std.draw.color('black')
        --std.draw.circle('fill', (posX + 16), (posY + 16), 28)
        std.draw.rect('fill', posX + 2, posY + 2, 28, 28)
    end
end

local function draw(std, game)
    
    -- fill background
    --std.draw.colorRgb(149, 165, 166)
    std.draw.color('black')
    std.draw.rect('fill', 0, 0, game.width, game.height)

    -- draw board perimeter
    std.draw.color('black')
    std.draw.rect('fill', game.boardStartX - 16, game.boardStartY - 16, game.boardColumns * 32 + 32, 16)
    std.draw.rect('fill', game.boardStartX - 16, game.boardStartY + (game.boardRows * 32), game.boardColumns * 32 + 32, 16)
    std.draw.rect('fill', game.boardStartX - 16, game.boardStartY, 16, game.boardRows * 32)
    std.draw.rect('fill', game.boardStartX + (game.boardColumns * 32), game.boardStartY, 16, game.boardRows * 32)

    -- draw 'debug' infos
    std.draw.color('white')
    std.draw.text(0, game.height - 16, 'game.width  ' .. game.width .. ' | game.height ' .. game.height)
    std.draw.text(0, game.height - 32, 'boardStartX ' .. game.boardStartX .. ' | boardStartY  ' .. game.boardStartY)
    std.draw.text(0, game.height - 48, 'game.playerPosX ' .. game.playerPosX)
    std.draw.text(0, game.height - 64, 'game.playerPosY ' .. game.playerPosY)
    std.draw.text(0, game.height - 80, 'loop count ' .. game.loopCount)
    std.draw.text(0, game.height - 96, 'state ' .. game.state)

    -- draw brocos
    local row = 0
    local column = 0
    local posX = 0
    local posY = 0
    for i = 1, (game.boardColumns * game.boardRows) do
        posX = game.boardStartX + (column * 32)
        posY = game.boardStartY + (row * 32)
        
        renderBroco(std, game, posX, posY, game.board[i])
        
        column = column + 1
        if(column >= game.boardColumns) then
            column = 0
            row = row + 1
        end
    end

    local startX = game.boardStartX + (game.boardColumns * 32) + 32
    local startY = game.boardStartY - 16

    -- draw selected broco
    --std.draw.colorRgb(192, 192, 192)
    std.draw.color('black')
    std.draw.rect('fill', startX, startY, 96, 96)
    startY = startY + 8
    std.draw.color('white')
    std.draw.text(startX + 16, startY, 'SELECTED')
    if game.selected > 0 then
        column = game.selectedColumn
        row = game.selectedRow
        renderBroco(std, game, startX + 32, startY + 32, game.selected)
        std.draw.color('white')
        std.draw.rect('line', game.boardStartX + (column * 32), game.boardStartY + (row * 32), 32, 32)
    end

    -- draw highscore
    --std.draw.colorRgb(192, 192, 192)
    std.draw.color('black')
    startY = startY + 96
    std.draw.rect('fill', startX , startY, 96, 64)
    std.draw.color('white')
    std.draw.text(startX + 16, startY + 8, 'HI-SCORE')
    std.draw.text(startX + 16, startY + 32, string.format("%07d", game.highscore))

    -- draw score
    startY = startY + 72
    --std.draw.colorRgb(192, 192, 192)
    std.draw.color('black')
    std.draw.rect('fill', startX , startY, 96, 64)
    std.draw.color('white')
    std.draw.text(startX + 16, startY + 8, '  SCORE')
    std.draw.text(startX + 16, startY + 32, string.format("%07d", game.score))

    -- draw broco count
    startY = startY + 72
    --std.draw.colorRgb(192, 192, 192)
    std.draw.color('black')
    std.draw.rect('fill', startX, startY, 120, 168)
    std.draw.color('white')
    std.draw.text(startX + 16, startY + 8, 'BROCO COUNT')
    renderBroco(std, game, startX + 16, startY + 32, 1) --square
    std.draw.color('white')
    std.draw.text(startX + 16 + 48, startY + 40, string.format("%05d", game.countSquares))
    renderBroco(std, game, startX + 16, startY + 64, 2) --diamond
    std.draw.color('white')
    std.draw.text(startX + 16 + 48, startY + 72, string.format("%05d", game.countDiamonds))
    renderBroco(std, game, startX + 16, startY + 96, 3) --triangle
    std.draw.color('white')
    std.draw.text(startX + 16 + 48, startY + 104, string.format("%05d", game.countTriangles))
    renderBroco(std, game, startX + 16, startY + 128, 4) --plus
    std.draw.color('white')
    std.draw.text(startX + 16 + 48, startY + 136, string.format("%05d", game.countPlus))

    -- draw player
    posX = game.boardStartX + (game.playerPosX * 32)
    posY = game.boardStartY + (game.playerPosY * 32)
    std.draw.color('white')
    std.draw.rect('line', posX, posY, 32, 32)
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
    config = {
        fps_drop = 5,
        fps_time = 15
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        exit=exit
    }
}

return P;