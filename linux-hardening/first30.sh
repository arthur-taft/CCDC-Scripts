#!/usr/bin/env bash

if (( EUID != 0 )); then
    echo "Script must be ran as root!"
    exit 1
fi

function backup_group_passwd() {
    tar -cJf /root/group_passwd.tar.xz /etc/group /etc/passwd
}

function backup_etc() {
    tar -cJf /root/ettc.tar.xz /etc 
}

function update_user_pass() {
    if [ -f /root/passupdate ]; then
        echo "Passwords have been updated. Skipping..."
    else 
        mapfile -t users < <(awk -F':' '{print $1}' /etc/passwd)

        printf "Username\tPassword"

        for user in "${users[@]}"; do
            if [ "$user" = "root" ]; then
                echo "Don't nuke the root user :)"
            else
                pass=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
                echo "$user:$pass" | chpasswd &>/dev/null

                printf "%s\t%s" "$user" "$pass"
            fi
        done
        touch /root/passupdate
    fi

    while :; do
    
        read -p "Have you written all this down? (y/n): " pass_check

        case "${pass_check,,}" in
            y)
                echo "Don't forget"
                break
                ;;
            n)
                echo "Go write that down"
                break
                ;;
            *)
                echo "Response must be 'y' or 'n'"
                ;;
            esac
    done
}

function service_backup() {
    mkdir /root/b
    chmod 600 /root/b

    tar -cJf /root/b/etc_bak.tar.xz /etc

    tar -cJf /root/b/web_bak.tar.xz /var/www/html

    if [ $(ss -autpn | grep splunk) ]; then
        tar -cJf /root/b/splunk_bak.tar.xz /opt
    fi

    tar -cJf /root/b/binary_bak.tar.xz /usr/bin/python3
}

function interface_down() {
    mapfile -t interfaces < <(ip -o link show | awk -F': ' '{print $2}')

    for iface in "${interfaces[@]}"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't nuke the loopback device :)"
        else
            ip link set "$iface" down
        fi
    done
}
