local math = require('math')
local util_decorator = require('src/lib/util/decorator')

--! @hideparam std
--! @hideparam engine
--! @hideparam self
local function add(std, engine, self, application)
    local index = #self.items + 1
    local node = application.node or std.node.load(application.node or application)

    std.node.spawn(node)
    node.config.parent = self.node

    self.items[index] = node
    
    if application.node then
        self.uis[application.node] = application
    end

    self:update_positions()

    return self
end

--! hideparam self
local function update_positions(self)
    local index = 1
    local hem = self.node.data.width / self.rows
    local vem = self.node.data.height / self.cols

    while index <= #self.items do
        local x = math.ceil(index / self.cols) - 1
        local y = (index - 1) %  self.cols
        local node = self.items[index]
        local ui = self.uis[node]
        node.config.offset_x = x * hem
        node.config.offset_y = y * vem
        index = index + 1
        node.data.width = hem
        node.data.height = vem
        if ui then
            ui:update_positions()
        end
    end

    return self
end

--! @hideparam std
--! @hideparam engine
local function grid(std, engine, layout)
    local rows, cols = layout:match('(%d+)x(%d+)')
    local node = std.node.load({})
    
    local grid_system = {
        rows=tonumber(rows),
        cols=tonumber(cols),
        items = {},
        uis = {},
        node=node,
        add=util_decorator.prefix2(std, engine, add),
        update_positions=update_positions
    }

    std.node.spawn(node)
    return grid_system
end

local function install(std, engine, application)
    std.ui = std.ui or {}
    std.ui.grid = util_decorator.prefix2(std, engine, grid)
end

local P = {
    install=install
}

return P
