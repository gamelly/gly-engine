local function build(src_in, bin_out)
    local src_file = io.open(src_in, 'r')
    local bin_file = io.open(bin_out, 'wb')

    if not src_file or not bin_file then
        return
    end

    local content = src_file:read('*a')
    local bytecode1 = loadstring and loadstring(content) or load(content)
    local bytecode2 = string.dump(bytecode1, true)
    src_file:close()

    bin_file:write(bytecode2)
    bin_file:close()
end

local P = {
    build = build
}

return P
