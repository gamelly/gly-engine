local math = require('math')
local util_decorator = require('src/lib/util/decorator')

--! @hideparam std
--! @hideparam engine
--! @hideparam self
local function add(std, engine, self, application, size)
    local index = #self.items_node + 1
    local node = application.node or std.node.load(application.node or application)

    std.node.spawn(node)
    node.config.parent = self.node

    self.items_node[index] = node
    self.items_size[index] = size or 1
    
    if application.node then
        self.items_ui[application.node] = application
    end

    self:update_positions()

    return self
end

local function get_item(self, id)
    return self.items_node[id]
end

--! hideparam self
local function update_positions(self)
    local index = 1
    local x, y = 0, 0
    local hem = self.node.data.width / self.rows
    local vem = self.node.data.height / self.cols

    while index <= #self.items_node do
        local node = self.items_node[index]
        local size = self.items_size[index]
        local ui = self.items_ui[node]

        node.config.offset_x = x * hem
        node.config.offset_y = y * vem
        node.data.width = size * hem
        node.data.height = vem

        x = x + size
        if x >= self.rows then
            y = y + 1
            x = 0
        end

        if ui then
            ui:update_positions()
        end
       
        index = index + 1
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
        items_node = {},
        items_size = {},
        items_ui = {},
        node=node,
        add=util_decorator.prefix2(std, engine, add),
        update_positions=update_positions,
        get_item=get_item
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
