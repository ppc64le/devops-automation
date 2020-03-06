#!/bin/bash -xe
mysql -e "CREATE DATABASE $DB_NAME;"
mysql -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO $DB_USER@'%' IDENTIFIED BY '${DB_PASSWORD}'";
mysql -e "flush privileges"
mysql -e "show databases;"
