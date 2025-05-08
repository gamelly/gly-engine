local function init(std, props)
    props.exclamation = '!'
    std.storage.get('message'):as('exclamation'):default('!!')
        :callback(function() std.storage.set('message', 'back!'):run() end)
        :run()
end

local function loop(std, props)
end

local function draw(std, props)
    std.draw.clear(std.color.blue)
    std.draw.color(std.color.white)
    std.text.font_size(16)
    std.text.print(std.text.print_ex(8, 8, 'Wellcome ') + 8, 8, tostring(props.exclamation))
end

local function exit(std, props)
end

local P = {
    meta={
        title='Wellcome!',
        author='RodrigoDornelles',
        description='say -Wellcome!- in firsty entry and -Wellcome Back- for returning visitors.',
        version='1.0.0'
    },
    config={
        require='storage json'
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        exit=exit
    }
}

return P;
