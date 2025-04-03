local version = require('src/version')

local function screen_ginga(args)
    if args and args.screen then
        return '-s '..args.screen
    end
    return ''
end

local function html5_src_engine(args)
    if args.enginecdn then
        local suffix = (args.core :match('_micro') or args.core :match('_lite') or ''):gsub('_', '-')
        return 'https://cdn.jsdelivr.net/npm/@gamely/gly-engine'..suffix..'@'..version..'/dist/main.lua'
    elseif args.core == 'html5_ginga' then
        return '${window.engine_code}'
    end
    return 'main.lua'
end

local function html5_src_game(args)
    if args.core == 'html5_ginga' then
        return '${window.game_code}'
    end
    return 'game.lua'
end

local P = {
    screen_ginga = screen_ginga,
    html5_src_game = html5_src_game,
    html5_src_engine = html5_src_engine
}

return P
