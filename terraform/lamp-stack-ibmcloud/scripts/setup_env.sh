#!/bin/bash -xe 
VAR_DB_PASSWORD="${VAR_DB_PASSWORD:-password}"
# wait for setup
while ! grep "Cloud-init .* finished" /var/log/cloud-init.log; do
    echo "$(date -Ins) Waiting for cloud-init to finish"
    sleep 2
done
until sudo apt-get update; do sleep 5; done # some hacky way to get apt-get to succeed at boot 
# install apache mariadb php 
sudo apt-get install software-properties-common -y
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.i3d.net/pub/mariadb/repo/10.4/ubuntu bionic main'
sudo apt-get update; apt-get install apache2 mariadb-server php php-mysql libapache2-mod-php -y
# restart services 
systemctl start apache2; systemctl enable apache2.service;systemctl start mariadb.service; systemctl enable mariadb.service
# setup php files 
echo '<?php
phpinfo();
?>' > /var/www/html/info.php
echo "<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>" > /etc/apache2/mods-enabled/dir.conf
echo '<?php
$user = "admin";
$password = "'${VAR_DB_PASSWORD}'";
$database = "example_database";
$table = "todo_list";

try {
  $db = new PDO("mysql:host=localhost;dbname=$database", $user, $password);
  echo "<h2>TODO</h2><ol>"; 
  foreach($db->query("SELECT content FROM $table") as $row) {
    echo "<li>" . $row['content'] . "</li>";
  }
  echo "</ol>";
} catch (PDOException $e) {
    print "Error!: " . $e->getMessage() . "<br/>";
    die();
}' > /var/www/html/todo_list.php
# create sql table 
mysql -e "delete from mysql.user where user='root' and host not in ('localhost', '127.0.0.1', '::1');"
mysql -e "CREATE DATABASE example_database;"
mysql -e "CREATE TABLE example_database.todo_list (     item_id INT AUTO_INCREMENT,     content VARCHAR(255),     PRIMARY KEY(item_id) );"
mysql -e "INSERT INTO example_database.todo_list (content) VALUES ('Get Lampstack on Power!');"
mysql -e "SELECT * FROM example_database.todo_list;"
mysql -e "GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY '${VAR_DB_PASSWORD}' WITH GRANT OPTION;"
mysql -e "flush privileges"
# restart apache 
sudo systemctl restart apache2
