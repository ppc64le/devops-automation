#!/bin/bash -xe
# Install cuda driver and libraries
# TODO make this script more user friendly when installing newer versions of cuda.
wget https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda-repo-ubuntu1804-10-1-local-10.1.105-418.39_1.0-1_ppc64el.deb
sudo dpkg -i cuda-repo-ubuntu1804-10-1-local-10.1.105-418.39_1.0-1_ppc64el.deb
sudo apt-key add /var/cuda-repo-10-1-local-10.1.105-418.39/7fa2af80.pub
sudo apt-get update
sudo apt-get install cuda -y
echo "SUCCESS: Cuda is now installed!"
