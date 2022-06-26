# pterodactyl-installer
#  pterodactyl-installer

Unofficial scripts for installing Pterodactyl Panel & Wings. Works with the latest version of Pterodactyl!

Read more about [Pterodactyl](https://pterodactyl.io/) here. This script is not associated with the official Pterodactyl Project.

## Features 

Auto installer for Ubuntu and Debien

Run 

| Operating System | Version | nginx support      | PHP Version |
| ---------------- | ------- | ------------------ | ----------- |
| Ubuntu           | 14.04   | :red_circle:       |             |
|                  | 16.04   | :red_circle: \*    |             |
|                  | 18.04   | :white_check_mark: | 8.0         |
|                  | 20.04   | :white_check_mark: | 8.0         |
|                  | 22.04   | :white_check_mark: | 8.0         |
| Debian           | 8       | :red_circle: \*    |             |
|                  | 9       | :white_check_mark: | 8.0         |
|                  | 10      | :white_check_mark: | 8.0         |
|                  | 11      | :white_check_mark: | 8.0         |
| CentOS           | 6       | :red_circle:       |             |
|                  | 7       | :white_check_mark: | 8.0         |
|                  | 8       | :white_check_mark: | 8.0         |

### Supported Wings operating systems

| Operating System | Version | Supported          |
| ---------------- | ------- | ------------------ |
| Ubuntu           | 14.04   | :red_circle:       |
|                  | 16.04   | :red_circle: \*    |
|                  | 18.04   | :white_check_mark: |
|                  | 20.04   | :white_check_mark: |
|                  | 22.04   | :white_check_mark: |
| Debian           | 8       | :red_circle: \*    |
|                  | 9       | :white_check_mark: |
|                  | 10      | :white_check_mark: |
|                  | 11      | :white_check_mark: |
| CentOS           | 6       | :red_circle:       |
|                  | 7       | :white_check_mark: |
|                  | 8       | :white_check_mark: |

_\* Ubuntu 16 and Debian 8 no longer supported since Pterodactyl does not actively support it._

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