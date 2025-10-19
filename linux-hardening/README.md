# Introduction

This is where all the Linux magic happens, a few things to note:

- The main script is `first30.sh` and relies HEAVILY on bash (not sh)

- A simplified version of the script without tmux or package management can be found at `simple-first30.sh`

- A few `.deb` and `.rpm` archives have been included just in case things get really bad, and should crutch the script into running again

# Installation

On a typical GNU/Linux system, you shouldn't need to install any extra packages to run the script. If more packages are required, the script will install them automatically

## Quick Install 

Run the following commands in a bash session of your choice:

```
wget https://github.com/SUU-Cybersecurity-Club/CCDC-Scripts/releases/latest/download/linux-hardening.tar.xz

tar -xf linux-hardening.tar.xz

cd linux-hardening

chmod +x first30.sh 

./first30.sh
```

If running the simple script complete the first 3 items, then run 

```
chmod +x simple-first30.sh 

./simple-first30.sh
```

# Features

- Makes a backup of essential files in `/etc`

- Changes the passwords of all users except for the root user to a random string

- Brings down all network interfaces while hardening is occuring for maximum security

- Creates a new backup user 

- Prompts the user to change the root user's password 

- Makes a backup of essential services running on the system

- Makes a backup of then nukes all user crontabs

- Removes SSH

- Removes Cockpit

## Optional Features

- Fix package manager repos to point to archive links

- Installs homebrew package manager
