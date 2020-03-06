#!/bin/bash -xe
. $SCRIPT_PATH/common.sh
for c in $@; do
  retry $c
done
