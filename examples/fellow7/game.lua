local App = {
    title = 'Grid System',
    author = '',
    version = '1.0.0',
    require = 'math',
    assets = {
        './assets/icon80x80.png:icon80x80.png'
    }
}

local Widget = {
    draw = function(std, data)
        std.draw.image('icon80x80.png')
    end
}

function App.key(std, data)
    data.slider:next(std.key.axis.x):apply()
end

function App.load(std, data)
    std.ui.style('selected')
        :pos_y(function(std, node)
            return node.config.offset_y - 100
        end)

    std.ui.style('home')
        :height(200)
        :pos_y(function(std, node, parent)
            return parent.data.height - node.data.height
        end)

    data.slider = std.ui.slide('6x1')
        :style_item_select('selected')
        :style('home')
        :add(Widget)
        :add(Widget)
        :add(Widget)
        :add(Widget)
        :add(Widget)
        :add(Widget)
        :apply()
end

return App
