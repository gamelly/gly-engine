--! @defgroup std
--! @{
--! @defgroup ui
--! @{

--! @hideparam std
--! @hideparam engine
--! @hideparam self
--! @param [in,out] application new column
--! @param [in] size column width in blocks
local function add(std, engine, self, application, size)
    if not application then return self end
    local index = #self.items_node + 1
    local node = application.node or std.node.load(application.node or application)

    std.node.spawn(node)
    node.config.parent = self.node

    self.items_node[index] = node
    self.items_size[index] = size or 1
    
    if application.node then
        self.items_ui[application.node] = application
    end

    return self
end

--! @hideparam std
--! @hideparam engine
--! @hideparam self
--! @param [in,out] list of application columns
local function add_items(std, engine, self, applications)
    local index = 1
    while applications and index < #applications do
        add(std, engine, self, applications[index])
        index = index + 1
    end
    return self
end

--! @hideparam self
--! @param [in] id item index
--! @return node
local function get_item(self, id)
    return self.items_node[id]
end

--! @renamefunc style
local function style(self, classlist)
    self.classlist = classlist
    return self
end

--! @hideparam std
--! @hideparam engine
local function apply(std, engine, self)
    local index = 1
    local x, y = 0, 0

    local index2 = 1
    local pipeline = std.ui.style(self.classlist).pipeline

    while index2 <= #pipeline do
        pipeline[index2](std, self.node, self.node.config.parent, engine.root)
        index2 = index2 + 1
    end
    
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
            ui:apply()
        end
       
        index = index + 1
    end

    return self
end

--! @}
--! @}

local P = {
    add=add,
    apply=apply,
    style=style,
    get_item=get_item,
    add_items=add_items,
}

return P
