#!/usr/bin/env bash

source ./colors.sh

function check_package_manager() {
    if [[ -z "$OS" ]]; then
        printf "${RED}[ERROR]${NC} No OS name provided to remove_package.\n"
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
