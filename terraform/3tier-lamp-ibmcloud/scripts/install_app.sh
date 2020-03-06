#!/bin/bash -xe
. $SCRIPT_PATH/common.sh
commands=('/tmp/scripts/install_common.sh' '/tmp/scripts/app/install_common.sh' '/tmp/scripts/app/configure_php.sh' '/tmp/scripts/app/setup_wordpress.sh' '/tmp/scripts/app/configure_wordpress.sh')
for c in "${commands[@]}"; do
  retry $c
done
