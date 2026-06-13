#/usr/bin/env bash

str="$1"
for (( i=0; i<${#str}; i++ )); do
  chr="${str:$i:1}"
  sleep 0.1
  wlrctl keyboard type "$chr"
done
