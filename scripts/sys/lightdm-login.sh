#!/bin/bash


zgrep -e "Error getting user list from org.freedesktop.Accounts" \
	-e "Stopped target Graphical Interface" \
	-e "Reached target \(Graphical Interface\|Shutdown\)" \
	$(/bin/ls /var/log/syslog* | sort -r) | sed 's/^[^:]*://' | sed 's/lightdm.*//'
