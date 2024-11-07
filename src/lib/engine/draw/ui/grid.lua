local ui_common = require('src/lib/engine/draw/ui/common')
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
--! @}
--! @}

local function component(std, engine, layout)
    local rows, cols = layout:match('(%d+)x(%d+)')
    local node = std.node.load({
        width = engine.current.data.width,
        height = engine.current.data.height
    })
    
    local self = {
        rows=tonumber(rows),
        cols=tonumber(cols),
        items_node = {},
        items_size = {},
        items_ui = {},
        node=node,
        classlist='',
        add=util_decorator.prefix2(std, engine, ui_common.add),
        add_items=util_decorator.prefix2(std, engine, ui_common.add_items),
        style=ui_common.style,
        apply=util_decorator.prefix2(std, engine, ui_common.apply),
        get_item=ui_common.get_item
    }

    if engine.root == engine.current then
        node.callbacks.resize = function()
            if node.config.parent ~= engine.root then
                node.callbacks.resize = nil
                return
            end
            if self.px_height then
                node.data.height = self.px_height
            else
                node.data.height = engine.root.data.height
            end
            node.data.width = engine.root.data.width
            self:apply()
        end
    end

    std.node.spawn(node)
    return self
end

local P = {
    component = component
}

return P
