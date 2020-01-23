#!/bin/bash -xe 
# Add LAMP packages in Ubuntu VM
# install apache mariadb php 
sudo apt-get install software-properties-common -y
sudo apt-get update; apt-get install apache2 mariadb-server php php-mysql libapache2-mod-php -y
# restart services 
systemctl start apache2; systemctl enable apache2.service;systemctl start mariadb.service; systemctl enable mariadb.service
