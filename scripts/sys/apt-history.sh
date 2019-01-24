#!/bin/bash

### idea: https://askubuntu.com/a/879860
### but doesn't list aptitude commands
# files=$(/bin/ls /var/log/apt/history.log /var/log/apt/history.log.*.gz | sort -r)
# zgrep 'Commandline: apt' $files | sed 's/^[^:]*:[^:]*: //'

defaults="true"

# command line arguments
while :; do
	case $1 in 
		--install)
			install="true"
			defaults="false"
			;;
		--upgrade)
			upgrade="true"
			defaults="false"
			;;
		--remove)
			upgrade="true"
			defaults="false"
			;;
		-?*)
			printf "Unknown option: %s\n" "$1" >&2
			exit
			;;
		*)
			break
	esac
	shift
done

# defaults
if [ "$defaults" == "true" ]; then
	echo "setting defaults"
	install="true";
	remove="true";
	upgrade="true";
fi
echo "// settings: install=$install, remove=$remove, upgrade=$upgrade" > /dev/stderr

cat_all() {
	zcat -f /var/log/dpkg.log* | sort
}


filter() {
	eol=$'\n'
	search=""

	if [ "$install" == "true" ]; then search="${search}$eol"'$3 == "install" { print }'; fi
	if [ "$remove" == "true" ]; then search="${search}$eol"'$3 == "remove" { print }'; fi
	if [ "$upgrade" == "true" ]; then search="${search}$eol"'$3 == "upgrade" { print }'; fi

	if [ "$search" == "" ]; then
		cat
	else
		awk -F' ' "$search"
	fi
}


cat_all | filter
