#!/bin/bash -xe
. $SCRIPT_PATH/common.sh
commands=('/tmp/scripts/wait_for_boot.sh' '/tmp/scripts/install_common.sh' '/tmp/scripts/setup_mongodb.sh' '/tmp/scripts/install_nodejs.sh' '/tmp/scripts/setup_path.sh' '/tmp/scripts/setup_app.sh')
for c in "${commands[@]}"; do
  retry $c
done
