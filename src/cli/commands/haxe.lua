local function build(args)
    local game_name = args.game
    local game_file = io.open(game_name, 'r')
    local game_content = game_file and game_file:read('*a')

    if not game_content then
        return false, 'game not found!'
    end

    local pattern_utf8 = '_G%.require%("lua%-utf8"%)'
    local replace_utf8 = 'select(2, pcall(require, "lua-utf8")) or select(2, pcall(require, "utf8")) or string'
    local pattern_object = 'std%.(%w+):(%w+)'
    local replace_object = 'std.%1.%2'

    game_content = game_content:gsub(pattern_utf8, replace_utf8)
    game_content = game_content:gsub(pattern_object, replace_object)

    game_file = io.open(game_name, 'w')
    game_file:write(game_content)
    return true
end

local P = {
    ['tool-haxe-build'] = build
}

return P
