#!/usr/bin/env bash

if (( EUID != 0 )); then
    echo "Script must be ran as root!"
    exit 1
fi

acct_bak_count=0 
etc_bak_count=0

function backup_group_passwd_shadow() {
    tar -cJf /root/group_passwd_shadow_bak_"$acct_bak_count".tar.xz /etc/group /etc/passwd /etc/shadow
    ((acct_bak_count++))
}

function backup_etc() {
    tar -cJf /root/etc_bak_"$etc_bak_count".tar.xz /etc 
    ((etc_bak_count++))
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
    
        read -rp "Have you written all this down? (y/n): " pass_check

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
    ((etc_bak_count++))

    tar -cJf /root/b/web_bak.tar.xz /var/www/html

    if [ $(ss -autpn | grep splunk) ]; then
        tar -cJf /root/b/splunk_bak.tar.xz /opt
    fi

    tar -cJf /root/b/binary_bak.tar.xz /usr/bin/python3
}

# TODO: Check for flag to disable this function 
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

# TODO: Figure out how to disable cockpit

function create_backup_usr() {
    while :; do
        read -rp "What do you want the backup user to be named?: " backup_usr

        read -rp "Create backup user with name $backup_usr? (y/n): " usr_confirm

        case "${usr_confirm,,}" in
            y)
                echo "Creating user now"
                useradd -m -G video,audio,wheel -s /bin/bash "$backup_usr"
                break
                ;;
            n)
                echo "Let's try that again"
                ;;
            *)
                echo "Response must be 'y' or 'n'"
                ;;
        esac
    done

    echo "Password for user $backup_usr will be set in the next step"
}

function second_pass_update() {
    declare -a pass_update_users

    pass_update_users=( "root" "$backup_usr" )

    for user in "${pass_update_users[@]}"; do
        echo "Updating $user password"
        echo "Password text entered will not be echoed to the terminal"
        
        while :; do
            # -rs preserves backslashes and reads as a secure string
            read -rs "Enter the new password for $user: " new_pass
            read -rs "Enter password again: " new_pass_again

            if [ "$new_pass" != "$new_pass_again" ]; then
                echo "Passwords do not match!"
                echo "Plaese try again"
            else 
                break
            fi
        done

        echo "$user:$new_pass" | chpasswd &>/dev/null
    done
}

function nuke_cron() {
    # Comment out every line but the first three
    sed -i '4,${/^[[:space:]]*$/! s/^/#/}' /etc/crontab

    # Backup, then nuke user crons
    tar -cJf /root/b/cron_bak.tar.xz /var/spool/cron/*
    rm -f /var/spool/cron/*
}

function interface_up() {
    for iface in "${interfaces[@]}"; do
        if [ "$iface" = "lo" ]; then
            echo "Don't touch the loopback device"
        else
            ip link set "$iface" up
        fi
    done
}

function os_name() {
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release > /dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=Debian
        VER=$(cat /etc/debian_version)
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s)
        VER=$(uname -r)
    fi
}

os_name

OS="${OS,,}"

if [ "$OS" = "ubuntu" ]; then
    # Fix version to work with integer comparison
    VER="${VER::-3}"
elif [[ "$OS" =~ "fedora" ]]; then
    # Shorten Fedora Linux to fedora
    OS="fedora"
fi

function check_package_manager() {
    if [[ -z "$OS" ]]; then
        echo "Error: No OS name provided to remove_package."
        exit 1
    fi

    case "$OS" in
        ubuntu|debian)
            echo "apt"
            ;;
        centos|rocky|almalinux|fedora)
            echo "yum"
            ;;
        arch)
            echo "pacman"
            ;;
        opensuse*)
            echo "zypper"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

package_manager=$(check_package_manager)
