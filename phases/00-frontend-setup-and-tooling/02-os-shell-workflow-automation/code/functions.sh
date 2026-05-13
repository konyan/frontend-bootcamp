#!/usr/bin/env bash

mkcd() { mkdir -p "$1" && cd "$1"; }

port-kill() {
    local port=$1
    lsof -ti :"$port" | xargs kill -9
}

node-version() {
    node --version
    pnpm --version
}
