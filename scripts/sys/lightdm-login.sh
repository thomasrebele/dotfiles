#!/bin/bash


zgrep --text -e "Error getting user list from org.freedesktop.Accounts" \
	-e "Stopped target Graphical Interface" \
	-e "Reached target \(Graphical Interface\|Shutdown\)" \
	-e "systemd\[1\]: Stopped" \
	$(/bin/ls -rt /var/log/syslog*) | sed 's/^[^:]*://' | sed 's/lightdm.*//' 
