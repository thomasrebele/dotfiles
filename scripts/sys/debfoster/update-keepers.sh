#!/bin/bash

# create list of essential packages, which are installed
dpkg -l | grep "^.i" | sed 's/:.*//' | awk '{print "^" $2}' > /tmp/uk-installed-packages.txt
dpkg-query -W -f='${Package} ${Priority}\n' | awk '/(required|important)$/ { print $1 }' | sort | uniq > /tmp/uk-essential.txt
grep -f /tmp/uk-installed-packages.txt /tmp/uk-essential.txt > /tmp/uk-keep-essential.txt

# concatenate files

newkeepers=/tmp/keepers.txt
libkeepers=/var/lib/debfoster/keepers

cat /tmp/uk-keep-essential.txt > $newkeepers
cat keepers keepers-$(hostname) | sed "s/#.*//" >> $newkeepers

mv $newkeepers $newkeepers.tmp
cat $newkeepers.tmp | sort | uniq | grep . > $newkeepers
sudo mv $libkeepers $libkeepers.tmp
sudo sh -c "cat $libkeepers.tmp | sort | uniq > $libkeepers"

sudo vimdiff $libkeepers $newkeepers 

