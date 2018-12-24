#!/bin/bash


pid=$(xprop | grep "PID" | sed 's/.*= //')


confirm() {
	read -p "$1 (y/n): " choice
		case "$choice" in 
		  y|Y ) return 0;;
		  n|N ) return 1;;
		  * ) echo "please enter y or n";;
		esac
		return 2
}

if [ "$pid" != "" ]; then
	
	echo "detected the following programm"
	echo "pid: " $pid
	echo

	cat /proc/$pid/cmdline
	echo
	echo

	if confirm "kill?"; then
		kill $pid

	fi

else
	echo PID not found
fi

