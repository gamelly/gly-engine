local dirs = { 'html', 'html/search' }
local found_error = false

local function rename_files(dir)
    for file in io.popen('find "' .. dir .. '" -type f -name "group__*"'):lines() do
        local new_name = file:gsub('group__', '')
        if new_name ~= file then
            local cmd = string.format('mv "%s" "%s"', file, new_name)
            local ok = os.execute(cmd)
            if not ok then
                print('Error renaming file: ' .. file)
                found_error = true
            end
        end
    end
end

local function update_file_references(dir)
    for file in io.popen('find "' .. dir .. '" -type f'):lines() do
        if file:match('%.html$') or file:match('%.js$') or file:match('%.css$') or file:match('%.xml$') then
            local f = io.open(file, 'r')
            if not f then
                print('Failed to open file: ' .. file)
                found_error = true
            else
                local content = {}
                local changed = false
                for line in f:lines() do
                    local newline = line:gsub('group__', '')
                    if newline ~= line then changed = true end
                    table.insert(content, newline)
                end
                f:close()

                if changed then
                    local f_write = io.open(file, 'w')
                    if not f_write then
                        print('Failed to write to file: ' .. file)
                        found_error = true
                    else
                        for _, line in ipairs(content) do
                            f_write:write(line .. '\n')
                        end
                        f_write:close()
                    end
                end
            end
        end
    end
end

local function fix_navbar_index()
    local filepath = dirs[1]..'/navtreedata.js'
    local f = io.open(filepath, 'r')
    local fixed = '0.html'
    local content = f:read('*a'):gsub('NAVTREEINDEX%s*=%s*%[([^%]]*)%]', function(s)
        return 'NAVTREEINDEX = ["'..fixed..'"]'
    end)
    f:close()
    f = io.open(filepath, 'w')
    f:write(content)
    f:close()
end

for _, dir in ipairs(dirs) do
    rename_files(dir)
    update_file_references(dir)
end
fix_navbar_index()

if found_error then
    error('Post-processing failed. Some files could not be renamed or edited.', 0)
end
