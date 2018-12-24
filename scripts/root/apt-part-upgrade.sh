#!/bin/bash

packages=$(aptitude search '?upgradable ?installed !?automatic' | awk '{print $2}')

echo "trying to install $packages"
read xyz

if [ "$1" == "" ];
then
	continue=0;
else
	continue=1;
fi

for i in $packages
do
	if [ "$i" == "$1" ];
	then
		continue=0
	fi

	if [ $continue == 1 ];
	then
		continue;
	fi

	aptitude install -y --safe-resolver $i;
	echo "pausing before starting next task";
	sleep 1;
done

