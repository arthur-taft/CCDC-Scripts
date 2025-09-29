#!/usr/bin/env bash

sed -i -e '/^mirrorlist/d;/^#baseurl=/{s,^#,,;s,/mirror,/vault,;}' /etc/yum.repos.d/CentOS*.repo

yum update

if [ $? -eq 1 ]; then
    sed -i -e '/^mirrorlist/d;/^baseurl=/{s,^#,,;s,/mirror,/vault,;}' /etc/yum.repos.d/CentOS*.repo
fi