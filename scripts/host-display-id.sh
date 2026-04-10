#!/bin/bash

cd /sys/class/drm/ || exit

outputs=$(grep -l "^connected$" card*/status 2>/dev/null | \
          sed -e 's|card[0-9]-||' -e 's|/status||' | \
          sort -u | \
          paste -sd "_" -)

echo "$(hostname)_$outputs"
