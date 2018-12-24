#!/bin/bash

# sshfs options
opt="-o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,follow_symlinks,cache=yes,auto_cache,kernel_cache,allow_other"

machines="e6540 tpt lame elvis"

try-mount() {
	echo sshfs $@
	sshfs $opt $@
}

elvis() {
	try-mount elvis:/home/trebele/workspace/elvis ~/workspace/elvis
	try-mount elvis:/home/trebele/ ~/remote/elvis-home
	try-mount elvis:/san/suchanek/yago3/ ~/remote/elvis-yago3
}

tpt() {
	try-mount tpt:/cal/homes/rebele/workspace/lame10 ~/workspace/lame10
	try-mount tpt:/cal/homes/rebele/ ~/remote/lame10-home
	try-mount tpt:/infres/ic2/rebele ~/remote/lame10-ic2
}

lame() {
	try-mount lame9:/infres/ir410/ic2/rebele ~/remote/lame10-ir410
}

e6540() {
	try-mount e6540:/home/tr/workspace/e6540 ~/workspace/e6540
	try-mount e6540:/home/tr/ ~/remote/e6540-home
}

if [ "$1" == "is-mounted" ];
then
	path=$2
	result=$(mount | grep sshfs | awk '{print $3}' | grep "^$(realpath $path)$")

	if [ "$result" == "" ];
	then
		#echo "$path is not mounted"
		exit -1;
	else
		#echo "$path is mounted"
		exit 0;
	fi

else
	if [ "$*" != "" ]; then
		machines="$*"
	fi

	for m in $machines;
	do
		if [ "$(ssh $m "echo 1")" == "1" ];
		then
			hostnamecmd="hostname --short";
			remoteHostname=$(ssh $m "$hostnamecmd")
			if [ "$remoteHostname" == "$($hostnamecmd)" ]; then 
				echo "machine $m remote $remoteHostname local $hostname";
				continue;
			fi
			echo "mounting for machine $m"
			$m
		fi
	done

fi

