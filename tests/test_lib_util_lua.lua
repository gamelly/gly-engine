local test = require('src/lib/util/test')
local mock_require = require('mock/require')
local without_os = false
local without_locale = false

local without_env_locale = false

require = mock_require.require({
    ['src/lib/util/lua'] = function()
        return dofile('src/lib/util/lua.lua')
    end,
    ['os'] = function()
        if without_os then return nil end
        if without_env_locale then
            return {
                setlocale = function()
                    return ''
                end,
                getenv = function(varname)
                    return ''  
                end
            }
        end
        if without_locale then
            return {
                setlocale = function()
                    return ''
                end,
                getenv = function(varname)
                    if varname == 'LANG' then return 'en_ES.UTF-8' end
                    return nil
                end
            }
        end
        return {
            setlocale = function()
                return 'LC_CTYPE=pt_BR'
            end,
            getenv = function(varname)
                return 'LANG=at_BR.UTF-8'
            end
        }
    end
})


local lua_util = require('src/lib/util/lua')

function test_no_support_utf8()
    jit = nil
    _VERSION = 'Lua 5.1'

    assert(lua_util.has_support_utf8() == false)
end

function test_lua_jit_support_utf8()
    jit = true
    _VERSION = 'Lua 5.1'

    assert(lua_util.has_support_utf8() == true)
end

function test_lua_5_3_support_utf8()
    jit = nil
    _VERSION = 'Lua 5.3'

    assert(lua_util.has_support_utf8() == true)
end

function test_sys_lang_with_env()
    without_locale = true
    local lua_util33 = require ('src/lib/util/lua')
    without_locale = false

    assert(lua_util33.get_sys_lang() == 'en-ES')
end

function test_sys_lang_nil_os()
    without_os = true
    local lua_util2 = require('src/lib/util/lua')
    without_os = false

    assert(lua_util2.get_sys_lang() == 'en-US')
end

function test_sys_lang_with_locale()	
    assert(lua_util.get_sys_lang() == 'pt-BR')
end

function test_sys_lang_no_locale_no_env()
    without_env_locale = true
    local lua_util2 = require('src/lib/util/lua')
    without_env_locale = false
    
    assert(lua_util2.get_sys_lang() == 'en-US')
end

test.unit(_G)
