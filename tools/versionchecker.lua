local cli_file = io.open('src/cli/commands/info.lua')
local cli_text = cli_file and cli_file:read('*a')
local cli_version = cli_text and cli_text:match('(%d+%.%d+%.%d+)')

local npm_file = io.open('npm-gly-cli.json')
local npm_text = npm_file and npm_file:read('*a')
local npm_version = npm_text and npm_text:match('(%d+%.%d+%.%d+)')

local doxygen_file = io.open('Doxyfile')
local doxygen_text = doxygen_file and doxygen_file:read('*a')
local doxygen_version = doxygen_text and doxygen_text:match('(%d+%.%d+%.%d+)')

print('cli.lua:', cli_version)
print('npm.js: ', npm_version)
print('doxygen:', doxygen_version)

assert(cli_version == npm_version)
assert(cli_version == doxygen_version)
