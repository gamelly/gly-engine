local function install(self, library, name)
    local std = self and self.std or {}

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
