#!/usr/bin/env bash

# TODO: Check for flag to disable this function 
function interface_down() {
    for iface in "$@"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't nuke the loopback device :)"
        else
            ip link set "$iface" down
        fi
    done
}
