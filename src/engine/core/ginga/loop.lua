local function install(std, game, application)
    local index = #application.internal.fixed_loop + 1
    application.internal.fixed_loop[index] = function ()
        application.callbacks.loop(std, game)    
    end
    return {
        loop=application.internal.fixed_loop[index]
    }
end

local P = {
    install=install
}

return P
