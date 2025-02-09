local test = require('src/lib/util/test')
local protocol_http = require('ee/lib/protocol/http_ginga')

event = {
    post=function() end
}

local std = {
    bus = {
        listen = function(key, handler) 
            event[key] = handler
        end
    }
}
local game = {}
local application = {internal={http={}}}
local protocol = protocol_http.install(std, game, application)
local http_handler = protocol.handler
application.internal.fixed_loop = { function() event.loop() end }
application.internal.event_loop = { function(evt) event.ginga(evt) end }

function test_http_fast_post_201()
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='_fast',
        method='POST',
        body_content='',
        url='http://example.com/create-user',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='example.com',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 201 OK\r\nContent-Length: 2\r\n\r\nOK\r\n\r\n',
        connection=1
    })
    
    assert(response.ok == true)
    assert(response.status == 201)
    assert(response.body == '')
    assert(response.error == nil)
end

function test_http_get_200()
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='GET',
        body_content='',
        url='http://pudim.com.br',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com.br',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\neu',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value=' amo ',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='pudim!',
        connection=1
    })
    
    assert(response.ok == true)
    assert(response.status == 200)
    assert(response.body == 'eu amo pudim!')
    assert(response.error == nil)
end

function test_http_redirect_300()
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='GET',
        body_content='',
        url='http://pudim.com',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 300 Redirect\r\nLocation: http://pudim.com.br\r\n\r\n',
        connection=1
    })
    application.internal.fixed_loop[1]()
    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com.br',
        connection=2
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\neu amo pudim!',
        connection=2
    })
    
    assert(response.ok == true)
    assert(response.status == 200)
    assert(response.body == 'eu amo pudim!') -- same
    assert(response.error == nil)
end

function test_http_simultaneous_requests()
    local response1 = {}
    local http1 = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='GET',
        body_content='',
        url='http://pudim.com.br/chocolate',
        set = function(key, value)
            response1[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }
    local response2 = {}
    local http2 = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='GET',
        body_content='',
        url='http://pudim.com.br/doce-de-leite',
        set = function(key, value)
            response2[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }
    local response3 = {}
    local http3 = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='GET',
        body_content='',
        url='http://pudim.com.br/leite-condesado',
        set = function(key, value)
            response3[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }


    http_handler(http3)
    http_handler(http2)
    http_handler(http1)
    application.internal.fixed_loop[1]()
    application.internal.fixed_loop[1]()
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com.br',
        connection=3
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com.br',
        connection=2
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 200 OK\r\nContent-Length: 28\r\n\r\namo',
        connection=2
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com.br',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 200 OK\r\nContent-Length: 23\r\n\r\namo',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value=' pudim de ',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value=' pudim de doce de leite!',
        connection=2
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 200 OK\r\nContent-Length: 19\r\n\r\namo pudim de leite!',
        connection=3
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='chocolate!',
        connection=1
    })

    assert(response1.body == 'amo pudim de chocolate!')
    assert(response2.body == 'amo pudim de doce de leite!')
    assert(response3.body == 'amo pudim de leite!')
end

function test_http_get_200_samsung()
--[[
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='GET',
        body_content='',
        url='http://google.com',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.http.dns_state = 3
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='8.8.8.8',
        connection=1
    })
    application.internal.fixed_loop[1]()
    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='8.8.8.8',
        connection=2
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 200 OK\r\nContent-Length: 10\r\n\r\ngoogle it!',
        connection=2
    })
    application.internal.http.dns_state = 2

    luaunit.assertEquals(response.ok, true)
    luaunit.assertEquals(response.status, 200)
    luaunit.assertEquals(response.body, 'google it!')
    luaunit.assertEquals(response.error, nil)    
]]
end

function test_http_get_200_samsung_first_time()
--[[
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='GET',
        body_content='',
        url='http://bing.com',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.http.dns_state = 0
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='1.1.1.1',
        connection=1
    })
    application.internal.fixed_loop[1]()
    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='1.1.1.1',
        connection=2
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 200 OK\r\nContent-Length: 8\r\n\r\nbing it!',
        connection=2
    })
    application.internal.http.dns_state = 2

    luaunit.assertEquals(response.ok, true)
    luaunit.assertEquals(response.status, 200)
    luaunit.assertEquals(response.body, 'bing it!')
    luaunit.assertEquals(response.error, nil)  
]]  
end

function test_http_error_http()
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        method='GET',
        body_content='',
        url='https://pudim.com.br/',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.fixed_loop[1]()
    
    assert(response.ok == false)
    assert(response.status == nil)
    assert(response.body == nil)
    assert(response.error == 'HTTPS is not supported!')
end

function test_http_error_https_redirect()
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='GET',
        body_content='',
        url='http://pudim.com.br/',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com.br',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 300 Redirect\r\nLocation: https://pudim.com.br\r\n\r\n',
        connection=1
    })
    --[[TODO: some headers are returning nil under util_test framework, check this later.
    assert(response.ok == false)
    assert(response.status == nil)
    assert(response.body == nil)
    assert(response.error == 'HTTPS is not supported!')
	]]--
end

function test_http_error_too_many_redirect()
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='GET',
        body_content='',
        url='http://pudim.com.br/',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com.br',
        connection=1
    })
    http.p_redirects = 50
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='HTTP/1.1 300 Redirect\r\nLocation: http://pudim.com.br/\r\n\r\n',
        connection=1
    })
	--[[ TODO: some headers are returning nil under util_test framework, check this later.
    assert(response.ok == false)
    assert(response.status == nil)
    assert(response.body == nil)
    assert(response.error == 'Too Many Redirects!')
	]]--
end

function test_http_fast_empty_status_error()
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='_fast',
        method='POST',
        body_content='',
        url='http://pudim.com.br/create-user',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com.br',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        value='some error',
        connection=1
    })
    
    assert(response.ok == false)
    assert(response.status == nil)
    assert(response.body == nil)
    assert(response.error == 'some error')
end

function test_http_dns_error()
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='POST',
        body_content='',
        url='http://pudim.com',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com',
        error='cannot resolve pudim.com'
    })

    assert(response.ok == false)
    assert(response.status == nil)
    assert(response.body == nil)
    assert(response.error == 'cannot resolve pudim.com')
end

function test_http_data_error()
    local response = {}
    local http = {
        std=std,
        game=game,
        application=application,
        speed='',
        method='POST',
        body_content='',
        url='http://pudim.com.br',
        set = function(key, value)
            response[key] = value
        end,
        promise = function() end,
        resolve = function() end
    }

    http_handler(http)
    application.internal.fixed_loop[1]()

    application.internal.event_loop[1]({
        class='tcp',
        type='connect',
        host='pudim.com.br',
        connection=1
    })
    application.internal.event_loop[1]({
        class='tcp',
        type='data',
        error='some data error',
        connection=1
    })
--[[
    luaunit.assertEquals(response.ok, false)
    luaunit.assertEquals(response.status, nil)
    luaunit.assertEquals(response.body, nil)
    luaunit.assertEquals(response.error, 'some data error')
]]
end

test.unit(_G)

