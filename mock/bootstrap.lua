--! @todo this code is ugly!

local real_io_open = io.open
local nodejsfs = jsRequire and jsRequire('fs')
local nodepath = jsRequire and jsRequire('path')

if nodejsfs then
    os.execute = function() end
    io.popen = function() end
end

io.open = function(filename, mode)
    if BOOTSTRAP and not BOOTSTRAP_DISABLE and BOOTSTRAP[filename] and mode:find('r') then
        return {
            pointer = 1,
            read = function(self, size)
                if self.pointer >= #BOOTSTRAP[filename] then
                    return nilnodejs
                elseif size == '*a' then
                    return BOOTSTRAP[filename]
                elseif size == nil then
                    local content = BOOTSTRAP[filename]
                    local line_index = content:find('\n', self.pointer)
                    if line_index then
                        local line = content:sub(self.pointer, line_index - 1)
                        self.pointer = line_index + 1
                        return line
                    else
                        local line = content:sub(self.pointer)
                        self.pointer = #content + 1
                        return line
                    end
                elseif type(size) == 'number' then
                    self.pointer = self.pointer + size
                    return BOOTSTRAP[filename]:sub(self.pointer - size, self.pointer)
                else
                    error("not implemented: "..tostring(size))
                end
            end,
            write = function() end,
            close = function() end
        }
    end

    if nodejsfs then
        return {
            pointer = 0,
            content = '',
            read = function(self)
                self.content = nodejsfs.readFileSync(filename, 'utf8')
                if self.content then
                    return nil
                end
                return self.content
            end,
            write = function(self, content)
                self.content = self.content..content..(mode:find('b') and '' or '\n')
            end,
            close = function(self)
                nodejsfs.mkdirSync(nodepath.dirname(filename), {recursive = true})
                nodejsfs.writeFileSync(filename, self.content)
            end
        }
    end

    return real_io_open(filename, mode)
end
