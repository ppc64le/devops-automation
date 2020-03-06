#!/bin/bash -xe
echo "[mysqld]
bind-address    = 0.0.0.0
server-id       = 2
relay-log       = /var/log/mysql/mysql-relay-bin.log
log_bin         = /var/log/mysql/mysql-bin.log
binlog_do_db    = wordpress" >> /etc/mysql/my.cnf
systemctl restart mysql
netstat --listen --numeric-ports | grep 3306
mysql -e "CHANGE MASTER TO MASTER_HOST='$MASTER_HOST',MASTER_USER='$MASTER_USER', MASTER_PASSWORD='$MASTER_PASSWORD',MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS;";
mysql -e "START SLAVE;"
mysql -e "SHOW SLAVE STATUS;"
