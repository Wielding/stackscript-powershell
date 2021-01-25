# Linode Stackscript for Ubuntu 20.04

This is a Linode Stackscript for creating an Ubuntu 20.04 server with a modified openssh-server configuration for better security and the latest Microsoft PowerShell.

The current user defined fields are:

**PUB_KEY**: contains your ssh public key to be added to authorized_keys.

**SSHD_PORT**: the port that the openssh-server with listen for connections.  The default is 22001.

The purpose of this script is to provide a base for deployment scripts written in PowerShell. 

I prefer PowerShell for automation due to the fact that I can debug them with Visual Studio Code remotely.

There is also a devcontainer configuration to assist in testing the script in a local container using the Visual Studio Code Remote Containers extension.


#### Includes
* Powershell
* openssh-server
* fail2ban
* git



