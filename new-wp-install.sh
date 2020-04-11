#!/bin/bash
# GET ALL USER INPUT
tput setaf 2; echo "Domain Name (eg. example.com)?"
read DOMAIN
tput setaf 2; echo "Username (eg. database name)?"
read USERNAME
tput setaf 2; echo "Updating OS................."
sleep 2;
tput sgr0
sudo apt-get update
tput setaf 2; echo "Sit back and relax :) ......"
sleep 2;
tput sgr0
cd /etc/nginx/sites-available/

sudo wget -qO "$DOMAIN" https://raw.githubusercontent.com/alexyz41/High-Traffic-wordpress-server-configuration/master/sites-available/example.com.conf
sudo sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sudo sed -i -e "s/www.example.com/$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/
sudo mkdir -p /var/www/"$DOMAIN"/public
cd /var/www/"$DOMAIN/public"
sudo systemctl restart nginx.service
sudo certbot --nginx -d "$DOMAIN" -d www."$DOMAIN" --redirect
cd /etc/nginx/sites-available
sudo sed -i "/ssl_dhparam \/etc\/letsencrypt\/ssl-dhparams.pem; # managed by Certbot/a  ssl_trusted_certificate  \/etc\/letsencrypt\/live\/$DOMAIN\/chain.pem;" "$DOMAIN"
sudo systemctl restart nginx.service
cd ~

PASS=`pwgen -s 14 1`

sudo mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $USERNAME;
CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USERNAME.* TO '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

cd /var/www/"$DOMAIN/public"
tput setaf 2; echo "Downloading Latest Wordpress...."
sleep 2;
tput sgr0
sudo wp core download --locale=es_ES --allow-root
sudo wp config create --dbname="$USERNAME" --dbuser="$USERNAME" --dbpass="$PASS" --allow-root
tput setaf 2; echo "Site title?"
read TITLE
tput setaf 2; echo "Wordpress username?"
read WPUSERNAME
tput setaf 2; echo "Wordpress email?"
read EMAIL
sudo wp core install --url="$DOMAIN" --title="$TITLE" --admin_user="$WPUSERNAME" --admin_password="$PASS" --admin_email="$EMAIL" --allow-root

sudo chown www-data:www-data -R /var/www/"$DOMAIN"/public
sudo systemctl restart nginx.service

echo
echo
tput setaf 2; echo "Here is your Credentials"
echo "--------------------------------"
echo "Website:    https://$DOMAIN"
echo "Dashboard:  https://$DOMAIN/wp-admin"
echo
tput setaf 4; echo "Database Name:   $USERNAME"
tput setaf 4; echo "Database Username:   $USERNAME"
tput setaf 4; echo "Database Password:   $PASS"
echo "--------------------------------"
tput sgr0
echo
echo
tput setaf 3;  echo "Installation & configuration succesfully finished."
echo
echo "Twitter @bajpangosh"
echo "E-mail: support@kloudboy.com"
echo "Bye! Your boy KLOUDBOY!"
tput sgr0
