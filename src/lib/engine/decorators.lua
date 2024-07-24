local function decorator_reset(callbacks, std, game)
    return function()
        if callbacks.exit then
            callbacks.exit(std, game)
        end
        if callbacks.init then
            callbacks.init(std, game)
        end
    end
end

local P = {
    poly=decorator_poly,
    reset=decorator_reset
}

return P;
