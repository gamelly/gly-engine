
--! @defgroup std
--! @{
--! @defgroup hash
--! @pre require @c hash
--! @{

--! @li https://softwareengineering.stackexchange.com/questions/49550/which-hashing-algorithm-is-best-for-uniqueness-and-speed
--!
--! @return integer 32bit
local function djb2(digest)
    local index = 1
    local hash = 5381
    while index <= #digest do
        local char = string.byte(digest, index)
        hash = (hash * 33) + char
        index = index + 1
    end

    hash = string.format('%08x', hash)
    hash = tonumber(hash:sub(#hash - 7), 16)

    return hash
end

--! @hideparam all_your_secrets
--! @return integer 32bit
local function fingerprint(all_your_secrets)
    local index = 1
    local digest = ''
    while index <= #all_your_secrets do
        local value = all_your_secrets[index]
        if type(value) == 'function' then
            digest = digest..tostring(value())
        else
            digest = digest..tostring(value)
        end
        index = index + 1
    end
    return djb2(digest)
end

--! @}
--! @}

local function install(std, engine, all_your_secrets)
    local id = fingerprint(all_your_secrets)
    std = std or {}
    std.hash = std.hash or {}
    std.hash.djb2 = djb2
    std.hash.fingerprint = function() return id end
    return {hash=std.hash}
end

local P = {
    install = install
}

return P
