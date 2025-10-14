#!/usr/bin/env bash

function interface_down() {
    if [ "$2" = "false" ]; then
        echo "Network interface modification is disabled"
    else
        for iface in "$@"; do
            if [ "$iface" = "lo" ]; then
                echo "Don't nuke the loopback device :)"
            else
                ip link set "$iface" down
            fi
        done
    fi
}
