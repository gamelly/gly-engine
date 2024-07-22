--! @short safe load game
--! @brief search by game in filesystem / lua modules
--! @li https://love2d.org/wiki/love.filesystem.getSource
local function loadgame(game_file)
    local cwd = '.'
    local application = nil
    local game_title = game_file and game_file:gsub('%.lua$', '') or 'game'
    
    if love and love.filesystem and love.filesystem.getSource then
        cwd = love.filesystem.getSource()
    end
    if loadfile then
        application = loadfile(cwd..'/'..game_title..'.lua')
    end
    if not application and pcall and require then
        local ok, app = pcall(require, game_title)
        application = ok and app
    end

    if type(application) == 'function' then
        application = application()
    end

    return application
end

local P = {
    loadgame = loadgame
}

return P
