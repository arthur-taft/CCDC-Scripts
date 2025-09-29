#!/usr/bin/env bash

if (( $EUID != 0 )); then
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

        for user in ${users[@]}; do
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
}