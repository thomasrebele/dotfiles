#!/bin/bash

# A script to test the grafical part of the dotfiles, using the lightdm display manager.
# It requires the following packages:
# - xautomation
# - xdotool
# - lightdm
#
# To grab keyboard: Press ctrl, press shift, release shift, release ctrl

# create temporary user
### #user=tmp_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
user=tmptr
pwd=a

sudo /usr/sbin/useradd -p $(openssl passwd -1 $pwd)  $user

keep_user=false
keep_files=false

if [ "$1" == "--keep" ]; then
	keep_user=true
	shift 1
elif [ "$1" == "--keep-files" ]; then
	keep_files=true
	shift 1
fi

# create nested session
dm-tool add-nested-seat --screen 1000x800
sleep 2

# search display
# TODO: find DISPLAY dynamically?
DISPLAY=:1.0

# login temporary user
xdotool type tmptr
xte 'key Tab'
sleep 0.1
xdotool type $pwd
xte 'key Return'

echo "waiting for user to login"
while ! $(w | grep -q tmptr); do
	sleep 0.1;
done

# executing install command
if [ "$#" -ge "1" ]; then
	sleep 1
	DIR=$(pwd)
	# DISPLAY=$DISPLAY xterm -e /bin/bash -l -c "cd $DIR; $@; sleep 60" &
	CMD="$DIR/$@; /bin/bash"
	echo $0: executing $CMD in xterm window
	sudo -u tmptr DISPLAY=:1.0 xterm -e /bin/bash -c "$CMD"
fi

###### maybe possible with xephyr?
#### disp=4
#### Xephyr -ac -screen 800x400 -br -reset -terminate 2> /dev/null :$disp & 
#### sudo -u $user startx --  :$disp

echo 
echo wait until session closed
echo 
while ps -eo user,comm | grep $(whoami) | grep --quiet Xephyr; do
	sleep 1
done

## read -p "print any key to clean up" -n 1 -s

. $(dirname "$0")/cleanup.sh
