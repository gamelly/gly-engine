local function install(std, game, application)
    application.callbacks.loop = application.callbacks.loop or function () end

    local event_loop = function()
        application.callbacks.loop(std, game)
    end

    return {
        event={loop=event_loop}
    }
end

local P = {
    install=install
}

return P
