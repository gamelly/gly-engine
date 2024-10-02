local os = require('os')

local function has_support_utf8()
    if jit then
        return true
    end

    if tonumber(_VERSION:match('Lua 5.(%d+)')) >= 3 then
        return true
    end

    return false
end

local function get_sys_lang()
    if not os then
        return 'en-US'
    end
    
    local lang, contry = (os.setlocale() or ''):match('LC_CTYPE=(%a%a).(%a%a)')

    if not lang then
        lang, country = (os.getenv('LANG') or ''):match('(%a%a).(%a%a)')
    end

    if not lang then
        lang, country = 'en', 'US'
    end
    
    return string.lower(lang)..'-'..string.upper(country)
end

local P = {
    has_support_utf8=has_support_utf8,
    get_sys_lang=get_sys_lang
}

return P
