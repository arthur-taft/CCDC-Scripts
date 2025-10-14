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

modify_iface=true

while getopts ":i" opt; do
    case "$opt" in
        i) 
            modify_iface=false
            ;;
        \?) 
            echo "Unknown option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

export modify_iface

# Track how many backups are made for versioning
acct_bak_count=0 
etc_bak_count=0

# Make array containing network interfaces
mapfile -t interfaces < <(ip -o link show | awk -F': ' '{print $2}')
export interfaces

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

export OS VER

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

function check_tmux() {
    tmux --help 
    
    tmux_status=$?

    if [ "$tmux_status" -ne "0" ]; then
        echo "tmux not detected, installing now..."
        install_package "$package_manager" "tmux"
    else
        echo "tmux found, skipping install"
    fi
}

function package_management() {
    nano --help

    nano_status=$?

    vim --help

    vim_status=$?

    if [ "$nano_status" -eq "0" ]; then
        remove_package "$package_manager" "nano"
    fi

    if [ "$vim_status" -ne "0" ]; then
        install_package "$package_manager" "vim"
    fi
}

# TODO: Figure out how to disable cockpit
# TODO: Update sshd config

# Backup acct things
export -f backup_group_passwd_shadow
export -f backup_etc
export -f service_backup
export -f create_backup_usr
# Updates root and backup user password
export -f second_pass_update
export -f check_package_manager
export -f install_package
export -f interface_down
export -f interface_up
export -f nuke_cron
export -f remove_package
# Updates all user passwords to a random string
export -f update_user_pass

function setup_tmux() {
    tmux new-session -d -s start \; \
        tmux select-window -t start:0 \; \
        select-pane -t 0\; \
        attach-session -t start \
        # Create 'user' tab
        tmux rename-window -t start:0 user \; \
            split-window -h \; \
            select-pane -t 0 \; \
                send-keys 'bash -c "update_user_pass"' C-m \; \
            select-pane -t 1 \; \
                send-keys 'bash -c "service_backup && interface_down interfaces modify_iface"' C-m \; \
            select-pane -t 0 \; \
                send-keys 'bash -c "create_backup_usr && second_pass_update"' C-m \; \
            select-pane -t 1 \; \
                send-keys 'bash -c "nuke_cron && backup_group_passwd_shadow && backup_etc && interface_up interfaces modify_iface"' C-m \;
        # Create banner tab
        tmux new-window -t start:1 -n 'banner' \; \
            split-window \; \
            split-window \; \
            select-pane -t 0 \; \
                send-keys 'vim /etc/ssh/sshd_config' C-m \; \
            select-pane -t 1 \; \
                send-keys 'vim /etc/issue.net' C-m \; \
            select-pane -t 2 \; \
                send-keys 'Banner /etc/issue.net in config and write issue' \;
}

backup_group_passwd_shadow

backup_etc

setup_tmux
