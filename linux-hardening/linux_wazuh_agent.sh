#!/bin/bash

# linux_wazuh_agent.sh

#! /bin/bash

# Get ip address
Wazuh_IP="$1"
if [[ -z "$Wazuh_IP" ]]; then
    echo "Error: No Wazuh_IP provided."
    exit 1
fi

# Get package manager
package_manager="$2"
if [[ -z "$package_manager" ]]; then
    echo "Error: No package manager provided."
    exit 1
fi

# yum install
yum_install(){
    # Import the GPG key:
    rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH

    # Add the repository:
    cat > /etc/yum.repos.d/wazuh.repo << EOF
[wazuh]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=EL-\$releasever - Wazuh
baseurl=https://packages.wazuh.com/4.x/yum/
protect=1
EOF

    # Install the Wazuh agent:
    WAZUH_MANAGER="$Wazuh_IP" yum install wazuh-agent
}

# apt install
apt_install(){
    # Install the GPG key:
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

    # Add the repository:
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

    # Update the package information:
    apt-get update

    # Install the Wazuh agent:
    WAZUH_MANAGER="$Wazuh_IP" apt-get install wazuh-agent
}

# zypper install
zypper_install(){
    # Import the GPG key:
    rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH

    # Add the repository:
    cat > /etc/zypp/repos.d/wazuh.repo << EOF
[wazuh]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=EL-$releasever - Wazuh
baseurl=https://packages.wazuh.com/4.x/yum/
protect=1
EOF

    # Refresh the repository:
    zypper refresh

    # Install the Wazuh agent:
    WAZUH_MANAGER="$Wazuh_IP" zypper install wazuh-agent
}

case "$package_manager" in
    apt)
        apt_install
        ;;
    yum)
        yum_install
        ;;
    zypper)
        zypper_install
        ;;
    *)
        echo "Error: Unsupported package manager."
        exit 1
        ;;
esac