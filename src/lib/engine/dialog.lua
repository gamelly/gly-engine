--! @defgroup std
--! @{
--! @defgroup dialog
--! @pre require @c dialog
--! @{

--! @startsalt
--! {^"Title"
--!   { my awesome text }
--!   { [Ok] | [Cancel] }
--! }
--! @endsalt
--! @par Example
--! @code
--! game.mydialog = std.dialog.create({
--!     style=std.dialog.style_msgbox,
--!     caption="Title",
--!     info="my awesome text",
--!     button1="Ok",
--!     button2="Cancel"
--! })
--! @endcode
local style_msgbox = 1

--! @startsalt
--! {^"Title"
--!   { question?       }
--!   { "response      "}
--!   { [Ok] | [Cancel] }
--! }
--! @endsalt
--! @par Example
--! @code
--! game.mydialog = std.dialog.create({
--!     style=std.dialog.style_input,
--!     caption="Title",
--!     info="Question?",
--!     button1="Ok",
--!     button2="Cancel"
--! })
--! @endcode
local style_input = 2

--! @startsalt
--! {^"Title"
--!   { {+item 1 } }
--!   { {+ <back:orange>item 2} }
--!   { {+item 3 } }
--!   { {+item 4 } }
--!   { [Ok] | [Cancel] }
--! }
--! @endsalt
--! @par Example
--! @code
--! game.mydialog = std.dialog.create({
--!     style=std.dialog.style_list,
--!     caption="Title",
--!     info="item 1\nitem 2\nitem 3\nitem 4",
--!     button1="Ok",
--!     button2="Cancel"
--! })
--! @endcode
local style_list = 3

--! @startsalt
--! {^"Title"
--!   { password?       }
--!   { "********      "}
--!   { [Ok] | [Cancel] }
--! }
--! @endsalt
--! @par Example
--! @code
--! game.mydialog = std.dialog.create({
--!     style=std.dialog.style_password,
--!     caption="Title",
--!     info="Password?",
--!     button1="Ok",
--!     button2="Cancel"
--! })
--! @endcode
local style_password = 4

--! @todo plantuml diagram
local style_tablist = 5

--! @todo plantuml diagram
local style_tablist_headers = 6

--! @startsalt
--! {^"Title"
--!  { ^ item 2 ^ }
--!  { [Cancel] | [OK] }
--! }
--! @endsalt
--! @par Example
--! @code
--! game.mydialog = std.dialog.create({
--!     style=std.dialog.style_selectlist,
--!     caption="Title",
--!     info="item 1\nitem 2\nitem 3\nitem 4",
--!     button1="Ok",
--!     button2="Cancel"
--! })
--! @endcode
local style_selectlist = 7

--! @short @n
--! @brief you can create you render or use carrosel
--! @par Example
--! @code
--! game.mydialog = std.dialog.create({
--!     style=std.dialog.style_selectlist,
--!     items=8
--! })
--! @endcode
local style_invisiblelist = 8

--! @hideparam std
--! @hideparam game
--! @pre options.align must be @c -1 @c 0 or @c 1
--! @param [in] options @c dict
--! @code
--! local options = {
--!     style=0,
--!     algin=0,
--!     caption="",
--!     info="",
--!     button1="",
--!     button2="",
--!     colors={}
--! }
--! @endcode
local function create(std, game, options)
    std.dialog.count = std.dialog.count + 1

    std.dialog.list[std.dialog.count] = {
        align = options.align or 0,
        x = options.x or (game.width/2),
        y = options.y or (game.height/2),
        style=options.style,
        title=options.caption,
        info=options.info,
        button1=options.button1,
        button2=options.button2,
        confirm=options.success,
        cancel=options.cancel
    }

    return std.dialog.count
end

--! @hideparam std
--! @hideparam game
local function show(std, game, dialog_id)
    if not std.dialog.list[dialog_id] then return end
    std.dialog.item = 1
    std.dialog.id = dialog_id
    std.dialog.ttl = game.milis
end

--! @hideparam std
--! @hideparam game
local function index(std, game, dialog_id)
    return std.dialog.id == dialog_id and std.dialog.item
end

--! @}
--! @}

--! @cond

local function key(std, game, application)
    if not std.dialog.id then return end
    local dialog_style = std.dialog.list[std.dialog.id].style
    local handler_func = application.callbacks.dialog or function() end

    local key_button = std.key.press.enter
    local key_y = std.key.press.down - std.key.press.up
    local key_x = std.key.press.left - std.key.press.right
    
    if dialog_style == std.dialog.style_msgbox then        
        
    elseif dialog_style == std.dialog.style_list then        
        std.dialog.item = std.math.clamp(std.dialog.item + key_y, 1, 4)
    end

    if key_button ~= 0 then
        std.dialog.response = key == 1
        handler_func(std, game)
        std.dialog.response = nil
        if std.dialog.ttl ~= game.milis then
            std.dialog.id = nil
        end
    end
end

local function install(std, game, application)
    application.callbacks = application.callbacks or {}
    std.dialog = {
        -- styles
        style_msgbox=style_msgbox,
        style_input=style_input,
        style_list=style_list,
        style_password=style_password,
        style_tablist=style_tablist,
        style_tablist_headers=style_tablist_headers,
        style_selectlist=style_selectlist,
        style_invisiblelist=style_invisiblelist,
        -- internal
        count = 0,
        list = {},
        callback = application.callbacks.dialog or function () end,
        -- api
        create = function(options) return create(std, game, options) end,
        show = function(dialog_id) return show(std, game, dialog_id) end,
        index = function(dialog_id) return index(std, game, dialog_id) end
    }

    local event_keydown = function()
        key(std, game, application)
    end

    return {
        event={keydown=event_keydown}
    }
end

local P = {
    install=install
}

return P
--! @endcond
