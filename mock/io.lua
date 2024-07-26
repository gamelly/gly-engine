local function open(commands)
    return function(command, mode)
        assert(commands[command] ~= nil, command:gsub('\n', '\\n'))
        return commands[command]
    end
end

local P = {
    open = open
}

return P
