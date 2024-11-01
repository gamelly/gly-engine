local function module_del(src_in, module_name)
    local content = ''
    local src_file, src_err = io.open(src_in, 'r')

    if not src_file then
        return false, src_err
    end

    local in_module = false
    local module_name2 = ''
    local module_name3 = ''
    local pattern1 = 'local ([%w_]+) = nil'
    local pattern2 = 'local ([%w_]+) = ([%w_]+)%(%)'
    local pattern3 = ':package%(\'([%w@%.]+)\', ([%w_]+)'
    local pattern4 = ':package%(\'([%w@%.]+)\', ([%w_]+), ([%w_]+)'
    local pattern5 = '([%w_]+) = function'

    repeat
        local line = src_file:read()
        if line then
            local skip_line = false
            local module_p1 = {line:match(pattern1)}
            local module_p2 = {line:match(pattern2)}
            local module_p3 = {line:match(pattern3)}
            local module_p4 = {line:match(pattern4)}
            local module_34 = module_p4 and #module_p4 > 0 and module_p4 or module_p3
            local module_p5 = {line:match(pattern5)}

            if module_p1 and #module_p1 > 0 and module_p1[1] == module_name then
                skip_line = true
            end
            if module_p2 and #module_p2 > 0 and module_p2[2] == module_name then
                skip_line = true
                module_name2 = module_p2[1]
            end
            if module_34 and #module_34 > 0 and module_34[2] then
                if module_34[2] == module_name2 and module_34[3] then
                    skip_line = true
                    module_name3 = module_34[3]
                end
                if module_34[3] == module_name2 then
                    skip_line = true
                end
            end
            if module_p5 and #module_p5 > 0 then
                local module = module_p5[1]
                if module == module_name or module == module_name2 or module == module_name3 then
                    in_module = true
                end
            end

            if in_module then
                if line == '-'..'-' then
                    in_module = false
                else
                    skip_line = true
                end
            end

            if not skip_line then
                content = content..line..'\n'
            end
        end
    until not line

    src_file:close()
    src_file = io.open(src_in, 'wb')
    src_file:write(content)
    src_file:close()

    return true
end

local P = {
    del = module_del
}

return P
