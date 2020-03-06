#!/bin/bash -xe
sudo apt install php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
mkdir -p /var/www/wordpress
# Transfer files to /var/www/wordpress location 
rsync -av -P /tmp/wordpress/. /var/www/wordpress
# Set file access permissions.
chown -R www-data:www-data /var/www/wordpress
find /var/www/wordpress -type d -exec chmod g+s {} \;
chmod g+w /var/www/wordpress/wp-content
chmod -R g+w /var/www/wordpress/wp-content/themes
chmod -R g+w /var/www/wordpress/wp-content/plugins
echo "Setup word press SUCCESS"
