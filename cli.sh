#!/bin/sh

if lua -v >/dev/null 2>&1; then
    lua ./src/cli/init.lua "$@"
elif luajit -v >/dev/null 2>&1; then
    ./src/cli/init.lua "$@"
else
    echo "Lua not found!"
    exit 1
fi
