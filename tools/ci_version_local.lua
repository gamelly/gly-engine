local cli_file = io.open('src/cli/commands/info.lua')
local cli_text = cli_file and cli_file:read('*a')
local cli_version = cli_text and cli_text:match('(%d+%.%d+%.%d+)')

local doxygen_file = io.open('Doxyfile')
local doxygen_text = doxygen_file and doxygen_file:read('*a')
local doxygen_version = doxygen_text and doxygen_text:match('(%d+%.%d+%.%d+)')

local native_file = io.open('src/engine/core/native/main.lua')
local native_text = native_file and native_file:read('*a')
local native_version = native_text and native_text:match('(%d+%.%d+%.%d+)')

local lite_file = io.open('src/engine/core/native/main.lua')
local lite_text = lite_file and lite_file:read('*a')
local lite_version = lite_text and lite_text:match('(%d+%.%d+%.%d+)')

print('lite:   ', lite_version)
print('native: ', native_version)
print('cli.lua:', cli_version)
print('doxygen:', doxygen_version)

assert(cli_version == doxygen_version)
assert(cli_version == lite_version)
assert(cli_version == native_version)
