#!/usr/bin/env bash

function interface_down() {
    local -n interfaces="$1"
    local flag="$2"

    if [ "$flag" = "false" ]; then
        echo "Network interface modification is disabled"
        return 0
    fi

    for iface in "${interfaces[@]}"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't nuke the loopback device :)"
        else
            ip link set "$iface" down
        fi
    done
}
