function interface_up() {
    for iface in "$@"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't touch the loopback device"
        else
            ip link set "$iface" up
        fi
    done
}
