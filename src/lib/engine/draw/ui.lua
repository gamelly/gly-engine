local math = require('math')
local util_decorator = require('src/lib/util/decorator')

--! @defgroup std
--! @{
--! @defgroup ui
--! @{
--!
--! @details
--! @page ui_grid Grid System
--!
--! The grid system is very versatile, and adjusts itself with the resolution and can be used by nesting one grid inside another,
--! the best of all is that in frameworks that limit you to thinking in 12 or 24 columns like
--! [bootstrap](https://getbootstrap.com/docs/5.0/layout/grid/)
--! you must define how many columns yourself.
--!
--! @par Example
--! @code{.java}
--! local function init(std, data)
--!     std.ui.grid('4x8 full6x8 ultra8x8')
--!         :add_items(list_of_widgets)
--! end
--! @endcode
--!
--! @par Breakpoints
--! @todo comming soon
--!
--! |        | 1seg | SD 480 | HD 720  | FULL HD 1080 | QUAD HD 1440 | ULTRA HD 4K |
--! | :----- |      | :----: | :-----: | :----------: | :----------: | :---------: |
--! | prefix |      | sd     | hd      | full         | quad         | ultra       |
--! | width  | >0px | >679px | >1279px | >1919px      | >2569px      | >3839px     |
--! 
--! @par Offset
--! To create blank columns, simply add an empty table @c {} to represent an empty node.
--! You can also specify the size of these whitespace columns as needed.
--! @startsalt
--! {+
--!   . | . | [btn0] 
--!   [btn1] | [btn2] | [btn3]
--! }
--! @endsalt
--! @code{.java}
--! std.ui.grid('3x2')
--!     :add({}, 2)
--!     :add(btn0)
--!     :add(btn1)
--!     :add(btn2)
--!     :add(btn3)
--! @endcode
--!
--! @par Columns
--!
--! You can add several different items to your grid: classes, nodes, offsets, entire applications and even another grid.
--!
--! @li @b class
--! @code{.java}
--! local btn = {
--!     draw=function(std, data)end
--! }
--! std.ui.grid('1x1'):add(btn)
--! @endcode
--!
--! @li @b node
--! @code{.java}
--! local btn_node = std.node.load(btn)
--! std.ui.grid('1x1'):add(node_btn)
--! @endcode
--!
--! @li @b offset
--! @code{.java}
--! std.ui.grid('1x1'):add({})
--! @endcode
--!
--! @li @b application
--! @code{.java}
--! local game = {
--!     meta={
--!        title='pong'
--!     },
--!     callbacks={
--!         init=function() end,
--!         loop=function() end,
--!         draw=function() end,
--!         exit=function() end
--!     }
--! }
--! std.ui.grid('1x1'):add(game)
--! @endcode
--! 
--! @li @b grid
--! @code{.java}
--! std.ui.grid('1x1')
--!      :add(std.ui.grid('1x1')
--!         :add(btn)
--!      )
--! @endcode

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

    self:update_positions()

    return self
end

--! @hideparam std
--! @hideparam engine
--! @hideparam self
--! @param [in,out] list of application columns
local function add_items(std, engine, self, applications)
    local index = 1
    while application and index < #application do
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

--! @cond
--! @todo better name
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
--! @endcond

--! @}
--! @}
local function grid(std, engine, layout)
    local rows, cols = layout:match('(%d+)x(%d+)')
    local node = std.node.load({
        width = engine.current.data.width,
        height = engine.current.data.height
    })
    
    local grid_system = {
        rows=tonumber(rows),
        cols=tonumber(cols),
        items_node = {},
        items_size = {},
        items_ui = {},
        node=node,
        add=util_decorator.prefix2(std, engine, add),
        add_items=util_decorator.prefix2(std, engine, add),
        update_positions=update_positions,
        get_item=get_item
    }

    if engine.root == engine.current then
        node.callbacks.resize = function()
            if node.config.parent ~= engine.root then
                node.callbacks.resize = nil
                return
            end
            node.data.width = engine.root.data.width
            node.data.height = engine.root.data.height
            grid_system:update_positions()
        end
    end

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
