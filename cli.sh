#!/bin/sh

set -e

if lua -v >/dev/null 2>&1; then
    lua ./src/cli/main.lua "$@"
elif luajit -v >/dev/null 2>&1; then
    ./src/cli/main.lua "$@"
else
    echo "Lua not found!"
    exit 1
fi
