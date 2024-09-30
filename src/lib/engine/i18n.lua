--! ISO 639
--! ISO 3166
local language = 'pt-BR'
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
--! @pre require @c i18n
--! @{

--! @par Example
--! @code
--! local some_tex t= std.i18n.get_text('some-text')
--! local width_some_text = std.draw.text(some_text)
--! std.draw.text(game.width - width_some_text, 8, some_text)
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
    language = l
end

--! @todo better example
--! @par Example
--! @code
--! std.i18n.back_language()
--! @endcode
local function back_language()
    local index = language_inverse_list[language]
    if index <= 1 then
        index = #language_list + 1
    end
    index = index - 1
    set_language(language_list[index])
end

--! @todo better example
--! @par Example
--! @code
--! std.i18n.next_language()
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

local function install(std, game, application)
    if not (std and std.draw and std.draw.text) then
        error('missing draw text')
    end

    local old_draw_text = std.draw.text
    local texts = application.callbacks.i18n(std, game)
    print(pcall(function()
        update_languages(texts)
    end))

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
    install=install
}

return P
