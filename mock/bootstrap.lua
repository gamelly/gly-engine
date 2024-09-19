--! @todo this code is ugly!

local io = io or {open = function(a, b) end, popen = function (a) end}
local javascript_path = jsRequire and jsRequire('path')
local javascript_fs = jsRequire and jsRequire('fs')
local real_io_open = io and io.open

if jsRequire then
    os.execute = function() end
    io.popen = function() end
end

local function bootstrap_io_open(filename, mode)
    return {
        pointer = 1,
        read = function(self, size)
            if self.pointer >= #BOOTSTRAP[filename] then
                return nil
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

local function javascript_io_open(filename, mode)
    return {
        pointer = 1,
        content = '',
        read = function(self)
            self.content = javascript_fs.readFileSync(filename, 'utf8')
            if self.content then
                return nil
            end
            return self.content
        end,
        write = function(self, content)
            self.content = self.content..content..(mode:find('b') and '' or '\n')
        end,
        close = function(self)
            javascript_fs.mkdirSync(javascript_path.dirname(filename), {recursive = true})
            javascript_fs.writeFileSync(filename, self.content)
        end
    }
end

io.open = function(filename, mode)
    local read_from_self = (not mode or mode:find('r')) and BOOTSTRAP[filename]
    
    if BOOTSTRAP and not BOOTSTRAP_DISABLE and read_from_self then
        return bootstrap_io_open(filename, mode)
    end

    if javascript_fs then
        return javascript_io_open(filename, mode)
    end

    return real_io_open(filename, mode)
end
