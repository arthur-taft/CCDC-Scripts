#!/usr/bin/env bash

source ./colors.sh

function interface_up() {
    local flag="$1"

    if [ "$flag" = "false" ]; then
        printf "${YELLOW}[WARN]${NC} Network interface modification is disabled\n"
        return 0
    fi

    for iface in "$@"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't touch the loopback device"
        else
            ip link set "$iface" up
        fi
    done
}
