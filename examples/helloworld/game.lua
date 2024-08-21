local function init(std, game)
end

local function loop(std, game)
end

local function draw(std, game)
    std.draw.clear(std.color.black)
    std.draw.color(std.color.white)
    std.draw.text(8 , 8, 'Hello world!')
end

local function exit(std, game)
end

local P = {
    meta={
        title='Hello world',
        author='RodrigoDornelles',
        description='say hello to the world!',
        version='1.0.0'
    },
    callbacks={
        init=init,
        loop=loop,
        draw=draw,
        exit=exit
    }
}

return P;
