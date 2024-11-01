#!/bin/sh

set -e

if [ -n "$LUA_BIN" ] && "$LUA_BIN" -v >/dev/null 2>&1; then
    "$LUA_BIN" ./src/cli/main.lua "$@"
elif lua -v >/dev/null 2>&1; then
    lua ./src/cli/main.lua "$@"
elif lua5.4 -v >/dev/null 2>&1 || lua54 -v >/dev/null 2>&1; then
    lua5.4 ./src/cli/main.lua "$@" || lua54 ./src/cli/main.lua "$@"
elif lua5.3 -v >/dev/null 2>&1 || lua53 -v >/dev/null 2>&1; then
    lua5.3 ./src/cli/main.lua "$@" || lua53 ./src/cli/main.lua "$@"
elif lua5.2 -v >/dev/null 2>&1 || lua52 -v >/dev/null 2>&1; then
    lua5.2 ./src/cli/main.lua "$@" || lua52 ./src/cli/main.lua "$@"
elif lua5.1 -v >/dev/null 2>&1 || lua51 -v >/dev/null 2>&1; then
    lua5.1 ./src/cli/main.lua "$@" || lua51 ./src/cli/main.lua "$@"
elif luajit -v >/dev/null 2>&1; then
    luajit ./src/cli/main.lua "$@"
else
    echo -e "Lua not found!\nPlease install Lua or set the LUA_BIN environment variable."
    exit 1
fi
