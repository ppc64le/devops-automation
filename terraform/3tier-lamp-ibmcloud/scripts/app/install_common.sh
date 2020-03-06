#!/bin/bash -xe
sudo apt-get -y install \
                 php-fpm php-mysql \
                 unzip nginx

echo "SUCCESS: common packages are now installed!"
