local style = {
    list = {},
    dict = {}
}

local function decorate_style(namespace, attribute)
    return function(self, value)
        self.pipeline[#self.pipeline + 1] = function(std, node, parent, root)
            local is_func = type(value) == 'function'
            node[namespace][attribute] =  is_func and value(std, node, parent, root) or value
        end
        return self
    end
end

local function component(std, engine, classname)
    local self = style.dict[classname]

    if not self then
        self = {
            pipeline = {},
            width = decorate_style('data', 'width'),
            height = decorate_style('data', 'height'),
            pos_y = decorate_style('config', 'offset_y'),
            pos_x = decorate_style('config', 'offset_x')
        }

        style.list[#style.list] = classname
        style.dict[classname] = self
    end

    return self
end

local P = {
    component = component
}

return P
