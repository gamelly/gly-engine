local http_util = require('src/lib/util/http')
local json = require('src/third_party/json/rxi')

local url = 'https://api.github.com/repos/gamelly/gly-engine/releases'
local ver_file = io.open('src/version.lua')
local ver_text = ver_file and ver_file:read('*a')
local lmajor, lminor, lpatch = (ver_text or '0.0.0'):match('(%d+)%.(%d+)%.(%d+)')
local version_local = (lmajor * 10000) + (lminor * 100) + lpatch

local cmd = http_util.create_request('GET', url).not_status().to_curl_cmd()
local pid = io.popen(cmd)
local stdout = pid:read('*a')
local github = json.decode(stdout)

pid:close()

local rmajor, rminor, rpatch = github[1]['tag_name']:match('(%d+)%.(%d+)%.(%d+)')
local version_remote = (rmajor * 10000) + (rminor * 100) + rpatch

print('local:', lmajor, lminor, lpatch)
print('remote:', rmajor, rminor, rpatch)

assert(version_local > version_remote, 'bump version!')
