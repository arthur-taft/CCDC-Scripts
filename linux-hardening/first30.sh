#!/usr/bin/env bash

if (( EUID != 0 )); then
    echo "Script must be ran as root!"
    exit 1
fi

source main/bak_usr_and_pass_update.sh 
source main/check_package_manager.sh
source main/get_os_name_ver.sh 
source main/install_package.sh
source main/interface_down.sh 
source main/interface_up.sh 
source main/nuke_cron.sh 
source main/remove_package.sh
source main/update_user_pass.sh 

# Track how many backups are made for versioning
acct_bak_count=0 
etc_bak_count=0

# Make array containing network interfaces
mapfile -t interfaces < <(ip -o link show | awk -F': ' '{print $2}')

# Get os name and version
get_os_name_ver
echo "OS=$OS VER=$VER" > /dev/null 2>&1 

# Clean things up
OS="${OS,,}"

if [ "$OS" = "ubuntu" ]; then
    # Fix version to work with integer comparison
    VER="${VER::-3}"
elif [[ "$OS" =~ "fedora" ]]; then
    # Shorten Fedora Linux to fedora
    OS="fedora"
fi

package_manager=check_package_manager

function backup_group_passwd_shadow() {
    tar -cJf /root/group_passwd_shadow_bak_"$acct_bak_count".tar.xz /etc/group /etc/passwd /etc/shadow
    ((acct_bak_count++))
}

function backup_etc() {
    tar -cJf /root/etc_bak_"$etc_bak_count".tar.xz /etc 
    ((etc_bak_count++))
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

# TODO: Figure out how to disable cockpit

