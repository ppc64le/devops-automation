#!/bin/bash

# Wait for cloud-init to complete

while [ ! -f /opt/freeware/var/lib/cloud/data/result.json ]; do
  echo -e "\033[1;36mWaiting for cloud-init..."
  sleep 1
done
