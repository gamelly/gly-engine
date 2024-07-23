local function open(commands)
    return function(command, mode)
        return commands[command]
    end
end

local P = {
    open = open
}

return P
