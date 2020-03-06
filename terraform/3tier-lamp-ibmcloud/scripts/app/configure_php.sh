#!/bin/bash -xe 
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default_original
phpversion=$(php -v | grep -Po '(?<=PHP )([0-9.]{3})')

echo 'server {

        # root /var/www/html;
        root /var/www/wordpress;
        # Add index index.php .php to the list if you are using PHP
        index index.php index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                #try_files $uri $uri/ =404;

                # This is cool because no php is touched for static content.
                # include the "$is_args$args" so non-default permalinks does not break when using query string
                try_files $uri $uri/ /index.php$is_args$args;
        }

        # pass PHP scripts to FastCGI server
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
        #
        #       # With php-fpm (or other unix sockets):
                fastcgi_pass unix:/var/run/php/php'$phpversion'-fpm.sock;
        #       # With php-cgi (or other tcp sockets):
        #       fastcgi_pass 127.0.0.1:9000;
        }
        location ~ /\.ht {
                deny all;
        }
        location = /favicon.ico {
                 log_not_found off;
                 access_log off;
                 expires max;
         }

        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
}' >  /etc/nginx/sites-available/default
systemctl stop php7.2-fpm
systemctl stop nginx
