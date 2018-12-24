#!/bin/bash

set +m

iping() {
  ping -c 1 $1 &> /dev/null && echo "$1 is up"
}

if [ "$#" == 0 ]; then
  lst=c{125..130}-{00..30}
else
  lst=$*
fi

lst=$(eval echo $lst)

for ip in $lst; do iping $ip & done

sleep 0.25
echo "press key"
read
