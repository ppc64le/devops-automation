#!/bin/bash -xe
echo "[mysqld]
bind-address    = 0.0.0.0
server-id       = 1
log_bin         = /var/log/mysql/mysql-bin.log
binlog_do_db    = wordpress" >> /etc/mysql/my.cnf
systemctl restart mysql
mysql -e "GRANT REPLICATION SLAVE ON *.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'";
mysql -e "flush privileges"
mysql -e "show databases;"
netstat --listen --numeric-ports | grep 3306
