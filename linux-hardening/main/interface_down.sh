# TODO: Check for flag to disable this function 
function interface_down() {
    interfaces=$1

    for iface in "${interfaces[@]}"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't nuke the loopback device :)"
        else
            ip link set "$iface" down
        fi
    done
}

interface_down "$1"
