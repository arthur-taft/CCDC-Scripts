#!/usr/bin/env bash

function interface_up() {
    local -n interfaces="$1"
    local flag="$2"

    if [ "$flag" = "false" ]; then
        echo "Modifying network interfaces is disabled"
        return 0
    fi

    for iface in "${interfaces[@]}"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't touch the loopback device"
        else
            ip link set "$iface" up
        fi
    done
}
