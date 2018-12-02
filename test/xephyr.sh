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

# create nested session
dm-tool add-nested-seat --screen 1000x800
sleep 2

# login temporary user
xdotool type tmptr
xte 'key Tab'
sleep 1
xdotool type $pwd
xte 'key Return'

###### maybe possible with xephyr?
#### disp=4
#### Xephyr -ac -screen 800x400 -br -reset -terminate 2> /dev/null :$disp & 
#### sudo -u $user startx --  :$disp


# wait until xephyr closed
while ps -eo user,comm | grep $(whoami) | grep --quiet Xephyr; do
	sleep 1
done

## read -p "print any key to clean up" -n 1 -s

./test-xephyr-cleanup.sh
