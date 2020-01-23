#!/bin/bash -xe
# To start this sets up a few mock php static pages such as phpinfo and a Todo list to query MariaDB
# setup php files 
# create sql table 
mysql -e "delete from mysql.user where user='root' and host not in ('localhost', '127.0.0.1', '::1');"
mysql -e "CREATE DATABASE example_database;"
mysql -e "CREATE TABLE example_database.todo_list (     item_id INT AUTO_INCREMENT,     content VARCHAR(255),     PRIMARY KEY(item_id) );"
mysql -e "INSERT INTO example_database.todo_list (content) VALUES ('Get Lampstack on Power!');"
mysql -e "SELECT * FROM example_database.todo_list;"
mysql -e "GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY '${VAR_DB_PASSWORD}' WITH GRANT OPTION;"
mysql -e "flush privileges"
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
# add main static page
mv /tmp/scripts/index.html /var/www/html
mv /tmp/scripts/TuxIBM.jpeg /var/www/html
# restart apache 
sudo systemctl restart apache2
