#!/usr/bin/env bash

if (( $EUID != 0 )); then
    echo "Script must be ran as root!"
    exit 1
fi

break_while=0

while (( break_while == 0 )); do

    read -p "Have you changed the root pw and added a backup user? (y/n): " pw_check

    case "$pw_check" in
        y)
            echo "Good job! :)"
            break
            ;;
        n)
            echo "Go do that! >:("
            exit 1
            ;;
        *)
            echo "Response has got to be 'y' or 'n' buddy"
            ;;
    esac

done

OS=$(#!/usr/bin/env bash

os_name() {
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

os_name_result=$(os_name)
echo "$os_name_result")

package_manager=$(#!/usr/bin/env bash

# Get the OS name lowercase
OS="$OS"
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
esac)

function remove_package() {
    local package_manager="$1"
    if [[ -z "$package_manager" ]]; then
        echo "No package manager provided to remove package :("
        exit 1
    fi

    local package_name="$2"
    if [[ -z "$package_name" ]]; then
        echo "No package name provided to remove package :("
        exit 1
    fi

    if [[ "$package_manager" == "unsupported" ]]; then
        echo "Unsupported operating system :("
        exit 1
    fi

    case "$package_manager" in
        apt)
            echo "Using apt to remove $package_name..."
            apt remove -y "$package_name"
            ;;
        dnf)
            echo "Using dnf to remove $package_name..."
            dnf remove -y "$package_name"
            ;;
        yum)
            echo "Using yum to remove $package_name..."
            yum erase -y "$package_name"
            ;;
        pacman)
            echo "Using pacman to remove $package_name..."
            pacman -R --noconfirm "$package_name"
            ;;
        zypper)
            echo "Using zypper to remove $package_name..."
            zypper remove -y "$package_name"
            ;;
        *)
            echo "Unsupported package manager :("
            exit 1
            ;;
    esac
}

function install_package() {
    local package_manager="$1"
    if [[ -z "$package_manager" ]]; then
        echo "Error: No package manager provided to install package :("
        exit 1
    fi

    local package_name="$2"
    if [[ -z "$package_name" ]]; then
        echo "Error: No package name provided to install package :("
        exit 1
    fi

    if [[ "$package_manager" == "unsupported" ]]; then
        echo "Error: Unsupported operating system :("
        exit 1
    fi

    case "$package_manager" in
        apt)
            echo "Using apt to install $package_name..."
            apt update && apt install -y "$package_name"
            ;;
        dnf)
            echo "Using dnf to install $package_name..."
            dnf install -y "$package_name"
            ;;
        yum)
            echo "Using yum to install $package_name..."
            yum install -y "$package_name"
            ;;
        pacman)
            echo "Using pacman to install $package_name..."
            pacman -Syu --noconfirm "$package_name"
            ;;
        zypper)
            echo "Using zypper to install $package_name..."
            zypper install -y "$package_name"
            ;;
        *)
            echo "Unsupported package manager :("
            exit 1
            ;;
    esac
}

function etc_backup() {
    cd /
    tar -cf ettc etc
    mv ettc /boot
}

function ssh_backup_and_remove() {
    if [ -e "/root/.ssh" ]; then
        tar -cf keys /root/.ssh
        mv keys /boot
    fi

    remove_package "$package_manager" "openssh-server"
}

function run_nmap() {
    install_package "$package_manager" "nmap"

    nmap -sV -T4 -p- localhost 2>&1| tee nmap.txt
}

function setup_firewall() {
    case "$OS" in
        ubuntu)
            if (( $VER < 20.04 )); then
                ufw status
                ufw status verbose
                ufw default deny incoming
                ufw allow 80
                ufw allow 80/tcp
                ufw deny out 25/tcp
                ufw enable
            elif (( $VER >= 20.04 )); then
                nft list ruleset
                nft add table inet filter
                nft add chain inet filter input { type filter hook input priority 0 \; policy drop\; }
                nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }
                nft add rule inet filter input tcp dport 80 accept
                nft add rule inet filter output tcp dport 25 drop
                nft list ruleset > /etc/nftables.conf
            fi
            ;;
        debian)
            if (( $VER < 10 )); then
                ufw status
                ufw status verbose
                ufw default deny incoming
                ufw allow 80
                ufw allow 80/tcp
                ufw deny out 25/tcp
                ufw enable
            elif (( $VER >= 10 )); then
                nft list ruleset
                nft add table inet filter
                nft add chain inet filter input { type filter hook input priority 0 \; policy drop\; }
                nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }
                nft add rule inet filter input tcp dport 80 accept
                nft add rule inet filter output tcp dport 25 drop
                nft list ruleset > /etc/nftables.conf
            fi
            ;; 
        fedora linux)
            if (( $VER < 32 )); then
                firewall-cmd --state
                firewall-cmd --lsit-all-zones
                firewall-cmd --set-target=DROP --permanent
                firewall-cmd --add-port=80/tcp --permanent
                firewall-cmd --add-service=http --permanent
                firewall-cmd --add-rich-rule='rule family="ipv4" destination port=25 protocol=tcp reject' --permanent
                firewall-cmd --reload
            elif (( $VER >= 32 )); then
                nft list ruleset
                nft add table inet filter
                nft add chain inet filter input { type filter hook input priority 0 \; policy drop\; }
                nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }
                nft add rule inet filter input tcp dport 80 accept
                nft add rule inet filter output tcp dport 25 drop
                nft list ruleset > /etc/nftables.conf
            fi
            ;;
        centos)
            firewall-cmd --state
            firewall-cmd --lsit-all-zones
            firewall-cmd --set-target=DROP --permanent
            firewall-cmd --add-port=80/tcp --permanent
            firewall-cmd --add-service=http --permanent
            firewall-cmd --add-rich-rule='rule family="ipv4" destination port=25 protocol=tcp reject' --permanent
            firewall-cmd --reload           
            ;;
    esac
}

function second_backup() {
    cd /
    tar -cf ettc2 /etc
    mv ettc2 /boot
}

function download_and_run_script() {
    curl -O https://github.com/SUU-Cybersecurity-Club/CCDC-Scripts/releases/latest/linux-hardening.tar.xz linux-hardening.tar.xz
    tar -xpf linux-hardening.tar.xz
    cd linux-hardening

    chmod +x start.sh linux_wazuh_agent.sh

    bash start.sh
}

etc_backup

ssh_backup_and_remove

run_nmap

setup_firewall

second_backup

download_and_run_script