--! @defgroup std
--! @{
--! @defgroup color
--! @{
--! @par Example
--! @code{.java}
--! std.draw.clear(std.color.black)
--! std.draw.color(std.color.white)
--! @endcode
--! @par Pallete
--! @call color
--! @par List
--! @call code

local white = 0xFFFFFFFF
local lightgray = 0xC8CCCCFF
local gray = 0x828282FF
local darkgray = 0x505050FF
local yellow = 0xFDF900FF
local gold = 0xFFCB00FF
local orange = 0xFFA100FF
local pink = 0xFF6DC2FF
local red = 0xE62937FF
local maroon = 0xBE2137FF
local green = 0x00E430FF
local lime = 0x009E2FFF
local darkgreen = 0x00752CFF
local skyblue = 0x66BFFFFF
local blue = 0x0079F1FF
local darkblue = 0x0052ACFF
local purple = 0xC87AFFFF
local violet = 0x873CBEFF
local darkpurple = 0x701F7EFF
local beige = 0xD3B083FF
local brown = 0x7F6A4FFF
local darkbrown = 0x4C3F2FFF
local black = 0x000000FF
local blank = 0x00000000
local magenta = 0xFF00FFFF

--! @call endcode
--! @}
--! @}

local function install(std)
    std = std or {}
    std.color = std.color or {}
    std.color.white = white
    std.color.lightgray = lightgray
    std.color.gray = gray
    std.color.darkgray = darkgray
    std.color.yellow = yellow
    std.color.gold = gold
    std.color.orange = orange
    std.color.pink = pink
    std.color.red = red
    std.color.maroon = maroon
    std.color.green = green
    std.color.lime = lime
    std.color.darkgreen = darkgreen
    std.color.skyblue = skyblue
    std.color.blue = blue
    std.color.darkblue = darkblue
    std.color.purple = purple
    std.color.violet = violet
    std.color.darkpurple = darkpurple
    std.color.beige = beige
    std.color.brown = brown
    std.color.darkbrown = darkbrown
    std.color.black = black
    std.color.blank = blank
    std.color.magenta = magenta
    return std.color
end

local P = {
    install = install
}

return P
