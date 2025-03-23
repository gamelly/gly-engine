local function screen_ginga(args)
    if args and args.screen then
        return '-s '..args.screen
    end
    return ''
end

local P = {
    screen_ginga = screen_ginga
}

return P
