#!/usr/bin/env bash

source ./colors.sh

function create_backup_usr() {
    while :; do
        read -rp "What do you want the backup user to be named?: " backup_usr

        read -rp "Create backup user with name $backup_usr? (y/n): " usr_confirm

        case "${usr_confirm,,}" in
            y)
                echo "Creating user now"
                useradd -m -G video,audio,wheel,sudo -s /bin/bash "$backup_usr"
                case "$?" in
                    0) printf "${GREEN}[SUCCESS]${NC} User successfully created\n" ;;
                    *)
                        printf "${RED}[ERROR]${NC} User NOT created. Trying again...\n"
                        continue
                        ;;
                esac
                break
                ;;
            n)
                echo "Let's try that again"
                ;;
            *)
                printf "${RED}[ERROR]${NC} Response must be 'y' or 'n'\n"
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
            read -rsp "Enter the new password for $user: " new_pass; echo # Add echo so we aren't stuck on the same line
            read -rsp "Enter password again: " new_pass_again; echo

            if [ "$new_pass" != "$new_pass_again" ]; then
                printf "${RED}[ERROR]${NC} Passwords do not match!\n"
            else 
                break
            fi
        done

        echo "$user:$new_pass" | chpasswd &>/dev/null
    done
}
