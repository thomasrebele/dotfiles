#!/bin/bash

user=tmptr

# kill processes of temporary user
while ps -eo user | grep --quiet $user; do
	for i in $(ps -eo pid,user | grep $user | awk '{print $1}'); do
		sudo kill -9 $i
	done
	sleep 1
done

# delete temporary user
if [ "$keep_user" == true ]; then
	# do nothing
	_IGNORE=
elif [ "$keep_files" == true ]; then
	sudo deluser $user
else
	sudo deluser --remove-home $user
fi

