#!/bin/bash

packages=$(aptitude search '?upgradable ?installed !?automatic' | awk '{print $2}')


tmp="/tmp/partial-upgrade"

echo "# trying to install packages" > "$tmp"
echo "$packages" > "$tmp"
vim "$tmp"

echo "continue? otherwise press ctrl+c"
read xyz

if [ "$1" == "" ];
then
	continue=0;
else
	continue=1;
fi

for i in $(cat $tmp | grep -v "^#")
do
	if [ "$i" == "$1" ];
	then
		continue=0
	fi

	if [ $continue == 1 ];
	then
		continue;
	fi

	aptitude install -y --safe-resolver "$i";
	echo "pausing before starting next task";
	sleep 1;
done

