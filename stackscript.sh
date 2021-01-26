#!/bin/bash

# This is a linode stackscript that installs powershell, adds a public key for ssh
# as well as changing sshd_config for some better security.
# it is the base for running powershell deployment scripts

# <UDF name="PUB_KEY" Label="Public key for ssh" />
# <UDF name="SSHD_PORT" Label="ssh listen port" Default="22001" />

set -e

# Save stdout and stderr
exec 6>&1
exec 5>&2

# Redirect stdout and stderr to a file
exec > ./StackScript.out
exec 2>&1

install_packages () {
    sudo apt-get update
    sudo apt-get upgrade -y   
    sudo apt-get install git cmake wget fail2ban build-essential openssh-server -y
}

install_powershell() {
    sudo apt-get update
    # Install pre-requisite packages.
    sudo apt-get install -y wget apt-transport-https software-properties-common
    if [ ! -f "./downloads/packages-microsoft-prod.deb" ]; then
        # Download the Microsoft repository GPG keys
        wget -P downloads -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
    fi
    # Register the Microsoft repository GPG keys
    sudo dpkg -i downloads/packages-microsoft-prod.deb
    # Update the list of products
    sudo apt-get update
    # Enable the "universe" repositories
    sudo add-apt-repository universe
    # Install PowerShell
    sudo apt-get install -y powershell
}

configure_ssh() {
    mkdir -p ~/.ssh 
    echo $PUB_KEY > ~/.ssh/authorized_keys
    SSHD_FILE=/etc/ssh/sshd_config
    sudo cp $SSHD_FILE ${SSHD_FILE}.`date '+%Y-%m-%d_%H-%M-%S'`.back

    echo "#### Config Changes" | sudo tee -a $SSHD_FILE

    sudo sed -i '/^#PasswordAuthentication/ d' $SSHD_FILE
    echo "PasswordAuthentication no" | sudo tee -a $SSHD_FILE

    sudo sed -i '/^#PermitEmptyPasswords/ d' /etc/ssh/sshd_config
    echo "PermitEmptyPasswords no" | sudo tee -a $SSHD_FILE

    sudo sed -i '/^#PermitRootLogin/ d' /etc/ssh/sshd_config
    echo "PermitRootLogin no" | sudo tee -a $SSHD_FILE

    sudo sed -i '/Port 22/ d' /etc/ssh/sshd_config
    echo "Port ${SSHD_PORT}" | sudo tee -a $SSHD_FILE

    sudo sed -i '/X11Forwarding yes/ d' /etc/ssh/sshd_config
    echo "X11Forwarding no" | sudo tee -a $SSHD_FILE

    sudo service ssh restart
}

if [ -f /etc/apt/sources.list ]; then
    install_packages
    install_powershell
    configure_ssh    
    pwsh -Command "& {\$ProgressPreference = 'SilentlyContinue'; Install-Module WieldingStackScript -AllowPrerelease -Force}"
    echo ""
    pwsh -Command "& {Import-Module WieldingStackScript; Get-MachineInfo}"
else
    echo "Your distribution is not supported by this script"
    exit
fi


echo "Done!!"

# Restore stdout and stderr
exec 1>&6 6>&-
exec 2>&5 5>&-
