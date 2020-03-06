#!/bin/bash -xe
function fail {
  echo $1 >&2
  exit 1
}

function retry {
  local max=5
  local delay=15
  for  n in $(seq 1 $max); do 
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    } 
  done
}
