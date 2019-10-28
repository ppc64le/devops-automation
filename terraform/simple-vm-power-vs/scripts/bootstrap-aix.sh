#!/bin/bash

# Increase file system sizes
chfs -a size=+2G /
chfs -a size=+2G /opt
chfs -a size=+2G /var
chfs -a size=+2G /usr

# Install MySQL
yum install -y MySQL.ppc
/opt/freeware/bin/mysqladmin -u root password 's3cur3Pa5sw0rd'
/opt/freeware/bin/mysql --user="root" --password="s3cur3Pa5sw0rd" --database="mysql" --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'loopback' IDENTIFIED BY 's3cur3Pa5sw0rd';"
/opt/freeware/bin/mysql --user="root" --password="s3cur3Pa5sw0rd" --database="mysql" --execute="FLUSH PRIVILEGES;"

# Load some test data in the database
yum update -y curl
yum install -y git
cd /
git clone https://github.com/jwcroppe/test_db.git
cd test_db
/opt/freeware/bin/mysql --user="root" --password="s3cur3Pa5sw0rd" < employees.sql
