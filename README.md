# pterodactyl-installer
#  pterodactyl-installer

Unofficial scripts for installing Pterodactyl Panel & Wings. Works with the latest version of Pterodactyl!

Read more about [Pterodactyl](https://pterodactyl.io/) here. This script is not associated with the official Pterodactyl Project.

## Features 

Auto installer for Ubuntu and Debien

Run 
Check the support and operating systems on the site of [Pterodactyl](https://pterodactyl.io/)


## Using the installation scripts

To use the installation scripts, simply run this command as root. The script will ask you whether you would like to install just the panel, just Wings or both.

```bash
bash <(curl -s https://pterodactyl.nathanvandijk.nl)
```

_Note: On some systems, it's required to be already logged in as root before executing the one-line command (where `sudo` is in front of the command does not work)._

## Firewall setup

The installation scripts can install and configure a firewall for you. The script will ask whether you want this or not. It is highly recommended to opt-in for the automatic firewall setup.


If you only want to test a specific distribution,

this script has only been tested on Ubuntu 20.02 lts

let me know if it works on other operating systems