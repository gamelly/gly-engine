local function install(std, game, application, library, name)
    std = std or {}
    std[name] = {
        encode=library.encode,
        decode=library.decode
    }
    
    return {[name]=std[name]}
end

local P = {
    install=install
}

return P
