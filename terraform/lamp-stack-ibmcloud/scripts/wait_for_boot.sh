#!/bin/bash
# This script will wait until able to acquire package manager lock
# After boot when able to login to the VM the distro might not have all services running
# this script waits for cloud init to finish and package manager able to update database 
# wait for cloud-init setup
while ! grep "Cloud-init .* finished" /var/log/cloud-init.log; do
    echo "$(date -Ins) Waiting for cloud-init to finish"
    sleep 2
done
# wait to acquire lock
until sudo apt-get update; do sleep 5; done # wait get apt-get to succeed at boot 
