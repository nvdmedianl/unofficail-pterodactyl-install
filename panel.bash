#!/bin/bash
set -e

###########################################################################################
#                                                                                         #
#                                                                                         #
#                                                                                         #
# Copyright (C) 2022 - 2022, Nathan van Dijk, <info@nathanvandijk.nl>                     #
#                                                                                         #
#                                                                                         #
#   You should have received a copy of the GNU General Public License                     #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.                #
#                                                                                         #
# https://github.com/NathantheDev/unofficail-pterodactyl-install/blob/master/LICENSE      #
#                                                                                         #
# This script is not associated with the official Pterodactyl Project.                    #
# https://github.com/NathantheDev/unofficail-pterodactyl-install                          #
#                                                                                         #
###########################################################################################


apt update
apt upgrade -y 

echo "On which domain name should this panel be installed? (FQDN)"
read ipaddress

echo "Enter your email address here for your eggs added later"
read mailaddress

echo "Enter your superadmin name here"
read usernamepanel

echo "Enter your superadmin email address here"
read mailadresspanel

echo "Enter your superadmin first name here"
read firstnamepanel

echo "Enter your superadmin last name here"
read lastnamepanel

echo "Enter your superadmin password here"
read passwordpanel

echo "Enter your mysql end user databse password here"
read mysqlpasswordpanel

echo "Enter your mysql backend user password here"
read mysqlpasswordbackend

FQDN="${ipaddress}"
USE_SSL=false
EMAIL="${mailaddress}"
MYSQL_USER="pterodactyl"
MYSQL_PASSWORD="${mysqlpasswordbackend}"
MYSQL_DATABASE="panel"
MYSQL_USER_PANEL="pterodactyluser"
MYSQL_PASSWORD_PANEL="${mysqlpasswordpanel}"
USER_EMAIL="${mailaddresspanel}"
USER_USERNAME="${usernamepanel}"
USER_FIRSTNAME="${firstnamepanel}"
USER_LASTNAME="${lastnamepanel}"
USER_PASSWORD="${passwordpanel}"

echo "Do you want SSL on this domain? (IPs cannot have SSL!) (y/n)"
read USE_SSL_CHOICE
if [ "$USE_SSL_CHOICE" == "y" ]; then
    USE_SSL=true
elif [ "$USE_SSL_CHOICE" == "Y" ]; then
    USE_SSL=true
elif [ "$USE_SSL_CHOICE" == "j" ]; then
    USE_SSL=true
elif [ "$USE_SSL_CHOICE" == "J" ]; then
    USE_SSL=true    
elif [ "$USE_SSL_CHOICE" == "n" ]; then 
    USE_SSL=false
elif [ "$USE_SSL_CHOICE" == "N" ]; then 
    USE_SSL=false
else
    echo "Answer not found, no SSL will be used."
    USE_SSL=false
fi

# Node exporter

useradd --no-create-home --shell /bin/false node_exporter
cd /root
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xvf node_exporter-1.0.1.linux-amd64.tar.gz
cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64
cd /etc/systemd/system
wget https://raw.githubusercontent.com/NathantheDev/unofficail-pterodactyl-install/main/node_exporter.service -O /etc/systemd/system/node_exporter.service
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
cd /
systemctl status node_exporter


# Netdata installatiom
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --non-interactive --stable-channel --disable-telemetry --stable-channel


# Example Dependency Installation
# -------------------------------
# Add "add-apt-repository" command
apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
# Add additional repositories for PHP, Redis, and MariaDB
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:chris-lea/redis-server
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
# Update repositories list
apt update
# Add universe repository if you are on Ubuntu 18.04
apt-add-repository universe
# Install Dependencies
echo "php install"
apt -y install php8.0 php8.0-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip} mariadb-server nginx tar unzip git redis-server
echo "php install done"

# Installing Composer
# -------------------
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Download Files
# --------------
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# Installation
# ------------
# Database Configuration
mysql -u root -e "CREATE USER '${MYSQL_USER}'@'127.0.0.1' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -u root -e "CREATE DATABASE ${MYSQL_DATABASE};"
mysql -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'127.0.0.1' WITH GRANT OPTION;"
mysql -u root -e "CREATE USER '${MYSQL_USER_PANEL}'@'127.0.0.1' IDENTIFIED BY '${MYSQL_PASSWORD_PANEL}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER_PANEL}'@'127.0.0.1' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES;"
sed -i -e "s/127.0.0.1/0.0.0.0/g" /etc/mysql/my.cnf
sed -i -e "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mysql
systemctl restart mysqld
cp .env.example .env
y | composer install --no-dev --optimize-autoloader
php artisan key:generate --force

# Environment Configuration
# -------------------------
if [ "$USE_SSL" == true ]; then
php artisan p:environment:setup --author=$EMAIL --url=https://$FQDN --timezone=Europe/Amsterdam --cache=redis --session=redis --queue=redis --redis-host=127.0.0.1 --redis-pass=null --redis-port=6379  --settings-ui=true
elif [ "$USE_SSL" == false ]; then
php artisan p:environment:setup --author=$EMAIL --url=http://$FQDN --timezone=Europe/Amsterdam --cache=redis --session=redis --queue=redis --redis-host=127.0.0.1 --redis-pass=null --redis-port=6379  --settings-ui=true
fi
php artisan p:environment:database --host=127.0.0.1 --port=3306 --database=$MYSQL_DATABASE --username=$MYSQL_USER --password=$MYSQL_PASSWORD

# Database Setup
# --------------
y | php artisan migrate --seed --force

# Locations Setup
# --------------
php artisan p:location:make --short=NVD-NL --long="This server runs in Tilburg"

# Node Setup
# ----------
curl -o cd /var/www/pterodactyl/app/Console/Commands https://raw.githubusercontent.com/NathantheDev/unofficail-pterodactyl-install/main/NodeCommand.php

# Add The First User
# --------------
php artisan p:user:make --email=$USER_EMAIL --username=$USER_USERNAME --name-first=$USER_FIRSTNAME --name-last=$USER_LASTNAME --password=$USER_PASSWORD --admin=1

# Set Permissions
# ---------------
chown -R www-data:www-data /var/www/pterodactyl/*

# Queue Listeners
# ---------------
# Crontab Configuration
cronjob="* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1"
(crontab -u root -l; echo "$cronjob" ) | crontab -u root -
# Create Queue Worker
curl -o /etc/systemd/system/pteroq.service https://raw.githubusercontent.com/NathantheDev/unofficail-pterodactyl-install/main/pteroq.service
sudo systemctl enable --now redis-server
sudo systemctl enable --now pteroq.service


systemctl stop nginx

# Creating SSL Certificates
# -------------------------
sudo apt update
sudo apt install -y certbot
sudo apt install -y python3-certbot-nginx
# Creating a Certificate
if [ "$USE_SSL" == true ]; then
certbot certonly -d ${FQDN} --standalone --agree-tos --register-unsafely-without-email
elif [ "$USE_SSL" == false ]; then
echo ""
fi

# Webserver Configuration
# -----------------------
if [ "$USE_SSL" == true ]; then
curl -o /etc/nginx/sites-available/pterodactyl.conf https://raw.githubusercontent.com/NathantheDev/unofficail-pterodactyl-install/main/pterodactyl-ssl.conf
sed -i -e "s/<domain>/${FQDN}/g" /etc/nginx/sites-available/pterodactyl.conf
elif [ "$USE_SSL" == false ]; then
curl -o /etc/nginx/sites-available/pterodactyl.conf https://raw.githubusercontent.com/NathantheDev/unofficail-pterodactyl-install/main/pterodactyl.conf
sed -i -e "s/<domain>/${FQDN}/g" /etc/nginx/sites-available/pterodactyl.conf
fi
# Enabling Configuration
sudo ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
systemctl restart nginx

# install wings 

curl -sSL https://get.docker.com/ | CHANNEL=stable bash
systemctl enable --now docker
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
chmod u+x /usr/local/bin/wings
curl -o /etc/systemd/system/wings.service https://raw.githubusercontent.com/NathantheDev/unofficail-pterodactyl-install/main/wings.service
systemctl enable --now wings


# Firewall Setup
ufw allow 80
ufw allow 443
ufw allow 8080
ufw allow 2022
ufw allow 9100
ufw allow 19999

cat > login.txt
Pterodactyl URL: ${FQDN}
Pterodactyl Gebruikersnaam: ${USER_EMAIL}
Pterodactyl Gebruikersnaam: ${USER_USERNAME}
Pterodactyl Wachtwoord: ${USER_PASSWORD}
MySQL Gebruiker: ${MYSQL_USER}
MySQL Database: ${MYSQL_DATABASE}
MySQL Wachtwoord: ${MYSQL_PASSWORD}
MySQL Panel Username="pterodactyluser"
MySQL Paneel password="${MYSQL_PASSWORD_PANEL}"
exit 

