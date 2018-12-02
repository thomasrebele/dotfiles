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
sudo deluser $user

