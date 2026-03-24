#!/usr/bin/env bash

source ./colors.sh

function install_package() {
    local package_manager="$1"
    if [[ -z "$package_manager" ]]; then
        printf "${RED}[ERROR]${NC} No package manager provided to install package :(\n"
        exit 1
    fi

    local package_name="$2"
    if [[ -z "$package_name" ]]; then
        printf "${RED}ERROR${NC} No package name provided to install package :(\n"
        exit 1
    fi

    if [[ "$package_manager" == "unsupported" ]]; then
        printf "${RED}ERROR${NC} Unsupported operating system :(\n"
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
