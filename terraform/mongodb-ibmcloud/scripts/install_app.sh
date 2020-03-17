#!/bin/bash -xe
# This scripts install the Mongo Express UI application and setups mongodb by calling individual scripts
# if scripts fail it will retry 
. $SCRIPT_PATH/common.sh
commands=('/tmp/scripts/wait_for_boot.sh' '/tmp/scripts/install_common.sh' '/tmp/scripts/setup_mongodb.sh' '/tmp/scripts/install_nodejs.sh' '/tmp/scripts/setup_path.sh' '/tmp/scripts/setup_app.sh')
for c in "${commands[@]}"; do
  retry $c
done
