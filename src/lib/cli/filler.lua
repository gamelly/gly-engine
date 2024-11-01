local template_prefix = '-'..'-GLYSTART\n'
local template_suffix = '\n-'..'-GLYEND'
local template = 'return {meta={title=\'G\',author=\'G\',version=\'0.0.0\'},callbacks={draw=function(s) s.draw.rect(0,8,8,8,8) end}}'

local function put(dest, size)
    local index = 0
    local template_size = #(template..template_prefix..template_suffix)
    local padding_size = size - template_size

    if padding_size < 0 then
        return false, 'minimal size: '..template_size..' bytes.'
    end

    local padding = string.rep('\n', padding_size)
    local dest_file, dest_error = io.open(dest, 'wb')
    
    if not dest_file then
        return false, dest_error
    end

    dest_file:write(template_prefix..template..padding..template_suffix)
    dest_file:close()
    
    return true
end

local P = {
    put=put
}

return P
