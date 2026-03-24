#!/usr/bin/env bash

source ./colors.sh

function interface_down() {
    local flag="$1"
    shift

    if [ "$flag" = "false" ]; then
        printf "${YELLOW}[WARN]${NC} Network interface modification is disabled\n"
        return 0
    fi

    for iface in "$@"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't nuke the loopback device :)"
        else
            ip link set "$iface" down
        fi
    done
}
