--! @defgroup std
--! @{

--! @pre require: @c csv
local function csv(in_str, out_table)
    local index1 = 1
    local headers = {}
    local pattern = '[^,]+'
    local next_line = in_str:gmatch('([^\r\n]*)\r?\n?')
    local line = next_line()
    local next_header = line:gmatch(pattern)

    repeat
        local header = next_header()
        headers[index1] = header
        index1 = index1 + 1
    until not header

    local index2 = 1
    repeat
        line = next_line()
        if line then
            local next_value = line:gmatch(pattern)
            index1 = 1
            repeat 
                local value = next_value()
                local header = headers[index1]
                if header and value and not out_table[index2] then
                    out_table[index2] = {}
                end
                if header and value then
                    out_table[index2][header] = value
                end
                index1 = index1 + 1
            until not value
        end
        index2 = index2 + 1
    until not line
end

--! @}

local function install(std)
    std = std or {}
    std.csv = csv
    return std.csv
end

local P = {
    install=install
}

return P
