local App = {
    title = 'Grid System',
    author = '',
    version = '1.0.0',
    require = 'math'
}

local ClimaTV = {
    draw = function(std, data)
        std.draw.color(std.color.red)
        std.draw.rect(1, 1, 1, data.width - 2, data.height - 2)
        local w, h = tostring(std.math.ceil(data.width)), tostring(std.math.ceil(data.height))
        std.draw.text(8, 8, 'Clima TV\n'..w..'x'..h)
    end
}

local HoraTv = {
    draw = function(std, data)
        std.draw.color(std.color.green)
        std.draw.rect(1, 1, 1, data.width - 2, data.height - 2)
        local w, h = tostring(std.math.ceil(data.width)), tostring(std.math.ceil(data.height))
        std.draw.text(8, 8, 'Clima TV\n'..w..'x'..h)
    end
}

local TestTv = {
    draw = function(std, data)
        std.draw.color(std.color.yellow)
        std.draw.rect(1, 1, 1, data.width - 2, data.height - 2)
        local w, h = tostring(std.math.ceil(data.width)), tostring(std.math.ceil(data.height))
        std.draw.text(8, 8, 'Clima TV\n'..w..'x'..h)
    end
}

function App.load(std, data)
    std.ui.grid('6x2')
        :add(ClimaTV, 3)
        :add(ClimaTV)
        :add(ClimaTV)
        :add(ClimaTV)
        :add(std.ui.grid('2x2')
            :add(HoraTv)
            :add(HoraTv)
            :add(HoraTv)
            :add(HoraTv),
            2
        )
        :add(TestTv, 3)
        :add(ClimaTV)
end

return App
