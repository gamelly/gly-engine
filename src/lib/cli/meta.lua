local application_default = require('src/lib/object/root')
local zeebo_module = require('src/lib/common/module')

local function replace(src, meta, default)
    if src and #src > 0 then
        return (src
            :gsub('{{id}}', meta.id or default.id)
            :gsub('{{title}}', meta.title or default.title)
            :gsub('{{author}}', meta.author or default.author)
            :gsub('{{company}}', meta.company or default.company)
            :gsub('{{version}}', meta.version or default.version)
            :gsub('{{description}}', meta.description or default.description)
            :gsub('{{tizen_package}}', meta.tizen_package or default.tizen_package)
        )
    end
    return ''
end

local function file(self, file)
    local file_copy = string.format("%s", file)
    self.pipeline[#self.pipeline + 1] = function()
        if not self.loaded then return end

        local content = ''
        local file_meta = io.open(file_copy, 'r')

        repeat
            local line = file_meta:read()
            content = content..replace(line, self.meta, application_default.meta):gsub('\n', '')..'\n'
        until not line

        file_meta:close()

        file_meta = io.open(file_copy, 'w')

        file_meta:write(content)
        file_meta:close()
    end
    return self
end

local function stdout(self, format)
    local format_copy = string.format("%s", format)
    if format_copy == 'json' then
        format_copy = '{"id":"{{id}}","title":"{{title}}","company":"{{company}}",'
        format_copy = format_copy..'"version":"{{version}}","description":"{{description}}"}'
    end
    self.pipeline[#self.pipeline + 1] = function()
        if not self.loaded then return end
        print(replace(format_copy, self.meta, application_default.meta))
    end
    return self
end

local function pipe(self)
    return function()
        self:run()
    end
end

local function run(self)
    local index = 1
    while index <= #self.pipeline do
        self.pipeline[index]()
        index = index + 1
    end
    return self
end

local function current(gamefile, application)
    local metadata = zeebo_module.loadgame(gamefile)

    if not application then
        application = {
            meta = application_default.meta,
            pipeline={},
            file=file,
            stdout=stdout,
            pipe=pipe,
            run=run
        }
    end

    if metadata then
        application.loaded = true
        application.meta = metadata.meta
    end

    return application
end

local function late(game)
    local game_copy = string.format("%s", game)
    local application = current()
    local eval = application.run
    application.run = function()
        current(game_copy, application)
        eval(application)
    end
    return application
end

local P = {
    current = current,
    late = late
}

return P
