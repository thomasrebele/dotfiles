#!/bin/bash

xfconf-query -c keyboard-layout -p /Default/XkbLayout -n -s de,us -t string
xfconf-query -c keyboard-layout -p /Default/XkbVariant -n -s neo,intl -t string
xfconf-query -c keyboard-layout -p /Default/XkbDisable -n -s false -t bool

# fix problem of xfdesktop in combination with xmonad: xfdesktop appears on top of all other windows
xfconf-query -c xfce4-session -p /sessions/Failsafe/Client4_Command -t string -t string -s xfdesktop -s -D


# setup panel, need to shutdown running pannel and xfconfd
# see https://askubuntu.com/a/224037

if ps -u $(whoami) | grep -q xfce4-panel 2>&1 > /dev/null; then
	xfce4-panel --quit
fi
pkill xfconfd

# TODO: use variable instead of hard-coded constant

SRC=~/.dotfiles/desktop/xfce.install/.config.dir/xfce4.dir/xfconf.dir/xfce-perchannel-xml.dir/xfce4-panel.xml
cp $SRC ~/.config/xfce4/xfconf/xfce-perchannel-xml

xfce4-panel &

# update keyboard layout
sleep 1
xfce4-panel --restart

