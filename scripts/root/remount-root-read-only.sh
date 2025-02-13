#!/bin/bash


confirm() {
	read -p "$1 (y/n): " choice
		case "$choice" in 
		  y|Y ) return 0;;
		  n|N ) return 1;;
		  * ) echo "please enter y or n";;
		esac
		return 2
}

echo "This command shuts down most services (also the graphical user interface)"
echo "As an alternative you might want to consider:"
echo "fsfreeze -f /"
echo "### do what you need to do"
echo "fsfreeze -u /"

if confirm "Stop services and kill programs with rw open files?"; then
	service lightdm stop
	echo "stopping services"
	for i in $(service --status-all 2>&1 | grep + | awk '{print $4}')
	do
		echo service $i stop
		service $i stop
	done
	service lightdm stop
	
	echo "killing programs"
	for i in $(fuser -v -m / 2>&1 | grep " F" | awk '{print $2}')
	do
		kill $i
	done
	
	echo "remount read-only"
	mount -no remount,ro /
fi
