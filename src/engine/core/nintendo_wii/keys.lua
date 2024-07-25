local function update(dt, std)
    std.key.press.up = love.wiimote.isDown(0, 'up') and 1 or 0
    std.key.press.down = love.wiimote.isDown(0, 'down') and 1 or 0
    std.key.press.left = love.wiimote.isDown(0, 'left') and 1 or 0
    std.key.press.right = love.wiimote.isDown(0, 'right') and 1 or 0
    std.key.press.red = love.wiimote.isDown(0, 'a') and 1 or 0
    std.key.press.green = love.wiimote.isDown(0, 'b') and 1 or 0
    std.key.press.yellow = love.wiimote.isDown(0, '1') and 1 or 0
    std.key.press.blue = love.wiimote.isDown(0, '2') and 1 or 0
    std.key.press.enter = love.wiimote.isDown(0, '+') and 1 or 0
end

local function install(std)
    if love then
        if love.update then
            local old_update = love.update
            love.update = function(dt)
                old_update(dt)
                update(dt, std)
            end
        else
            love.update = function(dt)
                update(dt, std)
            end
        end
    end

    return {}
end

local P = {
    install=install
}

return P
