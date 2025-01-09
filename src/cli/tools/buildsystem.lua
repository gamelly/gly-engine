local os = require('os')
local zeebo_pipeline = require('src/lib/util/pipeline')
local zeebo_module = require('src/lib/common/module')
local zeebo_bundler = require('src/lib/cli/bundler')
local zeebo_builder = require('src/lib/cli/builder')
local zeebo_assets = require('src/lib/cli/assets')
local zeebo_fs = require('src/lib/cli/fs')
local util_fs = require('src/lib/util/fs')
local lustache = require('third_party/lustache/olivinelabs')

local function add_step(self, command, options)
    if not self.selected then return self end
    if options and not options.when then return self end
    self.pipeline[#self.pipeline + 1] = function()
        os.execute(command)
    end
    return self
end

local function add_core(self, core_name, options)
    if core_name ~= self.args.core then
        self.selected = false
        return self
    end
    options = options or {}

    self.found = true
    self.selected = true
    self.bundler = ''

    if options.force_bundler or self.args.bundler then
        self.bundler = '_bundler/'
    end
    
    self.pipeline[#self.pipeline + 1] = function()
        if not options.src then return end
        local from = util_fs.file(options.src)
        local to = util_fs.path(self.args.dist..self.bundler, options.as or from.get_file())
        zeebo_builder.build(from.get_unix_path(), from.get_file(), to.get_unix_path(), to.get_file(), options.prefix or '')
    end

    if #self.bundler > 0 and options.src then 
        self.pipeline[#self.pipeline + 1] = function()
            local file = options.as or util_fs.file(options.src).get_file()
            zeebo_bundler.build(self.args.dist..self.bundler..file, self.args.dist..file)
        end
    end

    if options.assets then
        self.pipeline[#self.pipeline + 1] = function()
            local game = zeebo_module.loadgame(self.args.dist..'game.lua')
            zeebo_assets.build(game and game.assets or {}, self.args.dist)
        end
    end

    return self
end

local function add_file(self, file_in, options)
    if not self.selected then return self end

    self.pipeline[#self.pipeline + 1] = function()
        local from = util_fs.file(file_in)
        local to = util_fs.path(self.args.dist, (options and options.as) or from.get_file())
        zeebo_fs.move(from.get_fullfilepath(), to.get_fullfilepath())
    end

    return self
end

local function add_meta(self, file_in, options)
    if not self.selected then return self end
    self.pipeline[#self.pipeline + 1] = function()
        local from = util_fs.file(file_in)
        local to = util_fs.path(self.args.dist, (options and options.as) or from.get_file())
        local input = io.open(from.get_fullfilepath(), 'r')
        local output = io.open(to.get_fullfilepath(), 'w')
        local game = zeebo_module.loadgame(self.args.dist..'game.lua')
        local content = input:read('*a')
        if game then 
            content = lustache:render(content, {meta=game.meta})
        end
        output:write(content)
        output:close()
        input:close()
    end
    return self
end

local function add_license(self, arg_name_value, arg_require, license)
    self.pipeline[#self.pipeline + 1] = function()
        local arg_name, arg_val = arg_name_value:match('(%w+)=(%w+)')
        if arg_val == tostring(self.args[arg_name]) and not self.args[arg_require] then
            error('please use flag -'..'-'..arg_require..' to use '..license..' modules', 0)
        end
    end
    return self
end

local function from(args)
    local self = {
        args=args,
        found=false,
        selected=false,
        add_step=add_step,
        add_core=add_core,
        add_file=add_file,
        add_meta=add_meta,
        add_license=add_license,
        pipeline={}
    }

    self.run = function()
        if not self.found then
            return false, 'this core cannot be build!'
        end
        local success, message = pcall(zeebo_pipeline.run, self)
        return success, not success and message
    end

    return self
end

local P = {
    from=from
}

return P
