local language = 'en-US'
local language_default = 'en-US'

local language_list = {}
local language_inverse_list = {}

local translate = {}

local function update_languages(texts)
    local index = 1

    translate = texts
    language_list = {language_default}
    language_inverse_list = {[language_default]=1}

    repeat
        local lang = next(texts)
        if lang then
            index = index + 1
            language_inverse_list[lang] = index
            language_list[#language_list + 1] = lang
        end
    until lang
end

--! @defgroup std
--! @{
--! @defgroup i18n
--! @short API for Internationalization
--! @brief support multi-language games.
--! @pre require @c i18n
--! @details
--! The format of language must be @c aa-AA, respectively <b>ISO 639</b> and <b>ISO 3166</b>,
--! This module is based on the system language,
--! but can also store the last saved language.
--!
--! @par Example
--! @code
--! local function i18n(std, game)
--!     return {
--!         ['pt-BR'] = {
--!             ['hello world'] = 'ola mundo'
--!         },
--!         ['es-ES'] = {
--!             ['hello world'] = 'hola mundo'
--!         }
--!     }
--! end
--!
--! local function draw(std, game)
--!     std.draw.clear(std.color.black)
--!     std.draw.color(std.color.white)
--!     std.draw.text(8, 8, 'hello world')
--! end
--! 
--! local P = {
--!     meta = {
--!         title='Hello'
--!     },
--!     config = {
--!         require='i18n'
--!     },
--!     callbacks = {
--!         i18n=i18n,
--!         draw=draw
--!     }
--! }
--!
--! return P
--! @endcode
--! @{

--! @par Example
--! @code
--! local some_text = std.i18n.get_text('some-text')
--! std.draw.text(8, 8, rot32(some_text))
--! @endcode
local function get_text(old_text)
    local new_text = translate[language] and translate[language][old_text]
    return new_text or old_text
end

--! @par Example
--! @code
--! local language = std.i18n.get_language()
--! std.draw.text(8, 8, language)
--! @endcode
local function get_language()
    return language
end

--! @par Example
--! @code
--! std.i18n.set_langauge('en-US')
--! @endcode
local function set_language(l)
    if language_inverse_list[l] then
        language = l
    else 
        language = language_default
    end
end

--! @par Example
--! @code
--! if game.state == game.menu_lang and std.key.press.left then
--!     std.i18n.back_language()
--! end
--! @endcode
local function back_language()
    local index = language_inverse_list[language]
    if index <= 1 then
        index = #language_list + 1
    end
    index = index - 1
    set_language(language_list[index])
end

--! @par Example
--! @code
--! if game.state == game.menu_lang and std.key.press.right then
--!     std.i18n.next_language()
--! end
--! @endcode
local function next_language()
    local index = language_inverse_list[language]
    if index >= #language_list then
        index = 0
    end
    index = index + 1
    set_language(language_list[index])
end

--! @}
--! @}

local function decorator_draw_text(func)
    return function (x, y, text)
        if text then
            text = get_text(text)
        else
            x = get_text(x)
        end
        return func(x, y, text)
    end
end

--! @todo
local function event_bus(std, engine)
end

local function install(std, engine, system_language)
    if not (std and std.draw and std.draw.text) then
        error('missing draw text')
    end

    local old_draw_text = std.draw.text

    if system_language then
        set_language(system_language())
    end
    
    std.draw.text = decorator_draw_text(old_draw_text)
    std.i18n = {}
    std.i18n.get_text = get_text
    std.i18n.get_language = get_language
    std.i18n.set_language = set_language
    std.i18n.back_language = back_language
    std.i18n.next_language = next_language

    return {
        std={
            i18n=std.i18n,
            draw={
                text=std.draw.text
            }
        }
    }
end

local P = {
    event_bus=event_bus,
    install=install
}

return P
