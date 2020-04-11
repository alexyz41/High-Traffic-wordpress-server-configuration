#!/bin/bash
# GET ALL USER INPUT
tput setaf 2; echo "Domain Name (eg. example.com)?"
read DOMAIN
tput setaf 2; echo "Username (eg. database name)?"
read USERNAME
tput setaf 2; echo "Updating OS................."
sleep 2;
tput sgr0
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update

tput setaf 2; echo "Installing Nginx"
sleep 2;
tput sgr0
sudo apt-get install nginx zip unzip pwgen -y

tput setaf 2; echo "Sit back and relax :) ......"
sleep 2;
tput sgr0
cd /etc/nginx/sites-available/
sudo wget -qO "$DOMAIN" https://raw.githubusercontent.com/alexyz41/High-Traffic-wordpress-server-configuration/master/sites-available/example.com.conf
sudo sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sudo sed -i -e "s/www.example.com/www.$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/
sudo mkdir /etc/nginx/kloudboy
cd /etc/nginx/kloudboy
sudo wget -q https://raw.githubusercontent.com/alexyz41/High-Traffic-wordpress-server-configuration/master/kloudboy/general.conf
sudo wget -q https://raw.githubusercontent.com/alexyz41/High-Traffic-wordpress-server-configuration/master/kloudboy/php_fastcgi.conf
sudo wget -q https://raw.githubusercontent.com/alexyz41/High-Traffic-wordpress-server-configuration/master/kloudboy/wordpress.conf
sudo wget -q https://raw.githubusercontent.com/alexyz41/High-Traffic-wordpress-server-configuration/master/kloudboy/security.conf
sudo systemctl restart nginx.service
tput setaf 2; echo "Installing and configuring SSL with Letsencrypt"
sleep 2;
tput sgr0
sudo add-apt-repository ppa:certbot/certbot
sudo apt update
sudo apt install python-certbot-nginx
sudo certbot --nginx -d "$DOMAIN" -d www."$DOMAIN" --redirect
cd /etc/nginx/sites-available
sudo sed -i "/ssl_dhparam \/etc\/letsencrypt\/ssl-dhparams.pem; # managed by Certbot/a  ssl_trusted_certificate  \/etc\/letsencrypt\/live\/$DOMAIN\/chain.pem;" "$DOMAIN"
cd /etc/nginx/
sudo mv nginx.conf nginx.conf.backup
sudo wget -qO nginx.conf https://raw.githubusercontent.com/alexyz41/High-Traffic-wordpress-server-configuration/master/nginx.conf
sudo sed -i -e "s/example.com/$DOMAIN/" nginx.conf
sudo mkdir -p /var/www/"$DOMAIN"/public
cd /var/www/"$DOMAIN/public"
cd ~

tput setaf 2; echo "Nginx server installation completed.."
sleep 2;
tput sgr0
cd ~
sudo chown www-data:www-data -R /var/www/"$DOMAIN"/public
sudo systemctl restart nginx.service

tput setaf 2; echo "let's install php 7.3 and modules"
sleep 2;
tput sgr0
sudo apt install php7.3 php7.3-fpm -y
sudo apt-get -y install php7.3-intl php7.3-curl php7.3-gd php7.3-imap php7.3-readline php7.3-common php7.3-recode php7.3-mysql php7.3-cli php7.3-curl php7.3-mbstring php7.3-bcmath php7.3-mysql php7.3-opcache php7.3-zip php7.3-xml php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack  php7.3-soap
tput setaf 2; echo "Some php.ini Tweaks"
sleep 2;
tput sgr0
sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.3/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.3/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.3/fpm/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.3/fpm/php.ini
sudo sed -i "s/;max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.3/fpm/php.ini
sudo sed -i "s/max_input_time = .*/max_input_time = 1000/" /etc/php/7.3/fpm/php.ini
sudo systemctl restart php7.3-fpm.service

tput setaf 2; echo "Instaling MariaDB"
sleep 2;
tput sgr0
sudo apt install mariadb-server mariadb-client php7.3-mysql -y
sudo systemctl restart php7.3-fpm.service
sudo mysql_secure_installation
PASS=`pwgen -s 14 1`

sudo mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $USERNAME;
CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USERNAME.* TO '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

tput setaf 2; echo "Downloading wp-cli..."
sleep 2;
tput sgr0
cd ~
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

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
#sudo wp plugin install wp-super-cache --activate
#sudo wp theme install wp-super-cache --activate

echo
echo
tput setaf 2; echo "Here is your Credentials"
echo "--------------------------------"
echo "Website:    https://www.$DOMAIN"
echo "Dashboard:  https://www.$DOMAIN/wp-admin"
echo "WP user:  $WPUSERNAME"
echo "WP PASS:  $PASS"
echo "--------------------------------"
tput sgr0
echo
echo
tput setaf 3;  echo "Installation & configuration succesfully finished."
echo
tput sgr0
