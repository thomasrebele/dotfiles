#!/bin/bash

zgrep "Error getting user list from org.freedesktop.Accounts" $(/bin/ls /var/log/syslog* | sort -r) | sed 's/^[^:]*://' | sed 's/lightdm.*//'
