#!/usr/bin/env bash

function interface_up() {
    if [ "$2" = "false" ]; then
        echo "Modifying network interfaces is disabled"
    else
        for iface in "$@"; do
            if [ "$iface" = "lo" ]; then
                echo "Don't touch the loopback device"
            else
                ip link set "$iface" up
            fi
        done
    fi
}
