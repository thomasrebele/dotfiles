#!/bin/bash

files="$(find /var/log -name 'syslog*' -newermt $(date +%Y-%m-%d -d '28 day ago') 2> /dev/null)"

zgrep --text -e "Error getting user list from org.freedesktop.Accounts" \
	-e "Stopped target Graphical Interface" \
	-e "Reached target \(Graphical Interface\|Shutdown\)" \
	-e "systemd\[1\]: Stopped" \
	$(/bin/ls -rt $files) | sed 's/^[^:]*://' | sed 's/lightdm.*//' 
