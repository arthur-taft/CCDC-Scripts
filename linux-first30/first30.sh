#!/usr/bin/env bash

if (( $EUID != 0 )); then
    echo "Script must be ran as root!"
    exit 1
fi

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
            echo "Error: Unsupported package manager."
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

