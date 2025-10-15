#!/usr/bin/env bash

if (( EUID != 0 )); then
    echo Must be run as root!
    exit 1
fi

source ./main/bak_usr_and_pass_update.sh
source ./main/interface_down.sh
source ./main/interface_up.sh
source ./main/nuke_cron.sh
source ./main/update_user_pass.sh
source ./first30.sh

backup_group_passwd_shadow

backup_etc

update_user_pass; service_backup; interface_down "$modify_iface" "${interfaces[*]}"; create_backup_usr; second_pass_update; nuke_cron; backup_group_passwd_shadow; backup_etc; interface_up "$modify_iface" "${interfaces[*]}"

echo COMPLETE

