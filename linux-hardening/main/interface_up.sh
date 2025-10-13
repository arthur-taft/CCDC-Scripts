function interface_up() {
    interfaces=$1

    for iface in "${interfaces[@]}"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't touch the loopback device"
        else
            ip link set "$iface" up
        fi
    done
}
