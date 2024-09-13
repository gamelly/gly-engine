local function draw(std, game)
    if std.dialog.id == nil then return end
    local dialog = std.dialog.list[std.dialog.id]

    if dialog.style == std.dialog.style_msgbox then
        local w1, h1 = std.draw.text(dialog.title)
        local w2, h2 = std.draw.text(dialog.info)
        local w3, h3 = std.draw.text(dialog.button1)
        local wmax = std.math.max(w1, w2, w3) + 16
        local hmax = h1 + h2 + h3
        local algins = {[-1]= 0, [0]= -(wmax/2), [1]= -wmax}
        local align = algins[dialog.align]
        std.draw.color(std.color.darkgray)
        std.draw.rect(0, dialog.x + align, dialog.y, wmax, hmax)

        std.draw.color(std.color.red)
        std.draw.rect(1, dialog.x + align, dialog.y, wmax, hmax)
        std.draw.line(dialog.x + align, dialog.y + h1, dialog.x + align + wmax, dialog.y + h1)

        std.draw.color(std.color.white)
        std.draw.text(dialog.x + 8 + align, dialog.y, dialog.title)
        std.draw.text(dialog.x + 8 + align, dialog.y + h1, dialog.info)
        std.draw.text(dialog.x + 8 + align, dialog.y + h1 + h2, dialog.button1)
    end
end

local function install(self)
    local std = self and self.std or {}
    local game = self and self.game or {}
    local event = self and self.event or {}
    local application = self and self.application or {}
    event.draw[#event.draw + 1] = function()
        draw(std, game)
    end
end

local P = {
    install=install
}

return P
