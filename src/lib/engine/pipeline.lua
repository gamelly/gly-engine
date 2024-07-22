local function pipe(self)
    return function()
        self:run()
    end
end

local function run(self)
    local index = 1
    while self.pipeline and index <= #self.pipeline do
        self.pipeline[index]()
        index = index + 1
    end
    return self
end

local P = {
    pipe=pipe,
    run=run
}

return P
