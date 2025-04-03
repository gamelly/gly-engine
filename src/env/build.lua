local version = require('src/version')

local function need_atobify(args, text, render)
    local text = render and render(text) or text or true
    local in_html5 = args.core:match('html5') ~= nil
    local in_legacy = ('webos tizen ginga offline'):match(args.core:gsub('html5_', '')) ~= nil
    local by_core = in_html5 and in_html5
    return by_core and text
end

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
    elseif need_atobify(args) then
        return '${window.engine_code}'
    end
    return 'main.lua'
end

local function html5_src_game(args)
    if need_atobify(args) then
        return '${window.game_code}'
    end
    return 'game.lua'
end

local P = {
    need_atobify = need_atobify,
    screen_ginga = screen_ginga,
    html5_src_game = html5_src_game,
    html5_src_engine = html5_src_engine
}

return P
