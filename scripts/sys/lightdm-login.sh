#!/bin/bash

files="$(find /var/log -name 'syslog*' -newermt $(date +%Y-%m-%d -d '28 day ago') 2> /dev/null)"

zgrep --text -e "Error getting user list from org.freedesktop.Accounts" \
	-e "Stopped target Graphical Interface" \
	-e "Reached target \(Graphical Interface\|Shutdown\)" \
	-e "Reached target Sleep" \
	-e "Starting Suspend" \
	-e "systemd-sleep" \
	-e "systemd\[1\]: Stopped" \
	$(/bin/ls -rt $files) | \
	sed 's/^[^:]*://;  s/lightdm.*//;  s/^[0-9]\{4\}-\([^T]*\)T\(..:..\):[^ ]* orchestra-tre/\1 \2/' | \
	awk ' LAST != $1 { LAST = $1; print "---" } { print $0} '
