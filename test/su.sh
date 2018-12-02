#!/bin/bash

# A script to test the command line part of the dotfiles, using the su command.

# create temporary user
### #user=tmp_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
user=tmptr
pwd=a

sudo /usr/sbin/useradd -p $(openssl passwd -1 $pwd)  $user

keep_files=false

if [ "$1" == "--keep-files" ]; then
	keep_files=true
	shift 1
fi


if [ "$#" -ge "1" ]; then
	echo $0: executing "$@"
	sudo su $user "$@"

fi

sudo su - $user


. $(dirname "$0")/cleanup.sh



