--! @todo this code is ugly!

local io = io or {open = function(a, b) end, popen = function (a) end}
local javascript_path = jsRequire and jsRequire('path')
local javascript_fs = jsRequire and jsRequire('fs')
local real_io_open = io and io.open

if jsRequire then
    os.execute = function() end
    io.popen = function() end
end

local function bootstrap_has_file(filename, mode)
    if not BOOTSTRAP then return false end
    if BOOTSTRAP_DISABLE then return false end
    if not BOOTSTRAP[filename] then return false end
    if mode and not mode:find('r') then return false end
    return true
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
                local content = BOOTSTRAP[filename]:sub(self.pointer, self.pointer + size)
                self.pointer = self.pointer + #content
                return content
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
            if self.content and #self.content > 0 then
                return nil
            end
            self.content = javascript_fs.readFileSync(filename, 'utf8')
            return self.content
        end,
        write = function(self, content)
            self.content = self.content..content..(mode:find('b') and '' or '\n')
        end,
        close = function(self)
            javascript_fs.mkdirSync(javascript_path.dirname(filename), {recursive = true})
            if mode:find('b') then
                local blob, index = {}, 1
                while index <= #self.content do
                    blob[index] = string.byte(self.content, index)
                    index = index + 1
                end
                javascript_fs.writeFileSync(filename, Buffer.from(blob))
            else
                javascript_fs.writeFileSync(filename, self.content)
            end
        end
    }
end

io.open = function(filename, mode)
    if bootstrap_has_file(filename, mode) then
        return bootstrap_io_open(filename, mode)
    end

    if javascript_fs then
        return javascript_io_open(filename, mode)
    end

    return real_io_open(filename, mode)
end
