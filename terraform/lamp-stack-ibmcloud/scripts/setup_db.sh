#!/bin/bash -xe
sudo systemctl stop mariadb
sudo rsync -av /var/lib/mysql /mnt/block-storage/mysql
sudo chown mysql:mysql /mnt/block-storage/mysql
sed -i -E 's/(datadir.+\=).+/\1 \/mnt\/block-storage\/mysql\/mysql/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo mv /var/lib/mysql /var/lib/mysql.bak
sudo systemctl start mariadb
