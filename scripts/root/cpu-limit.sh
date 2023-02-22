#!/bin/bash

if [ "$1" == "" ]; then
	echo "usage: <search-pattern>"
fi

# TODO: migrate to cgroup v2

### old code for cgroup v1
## cgcreate -g cpu:/cpulimit
## cgset -r cpu.cfs_period_us=1000000 cpulimit
## cgset -r cpu.cfs_quota_us=100000 cpulimit
## cgget -g cpu:cpulimit

cgroup="/sys/fs/cgroup/cpu-limit"
mkdir $cgroup
echo '+cpu -memory' > $cgroup/cgroup.subtree_control

#cmd=$(ps aux | grep -v "$0" | grep -v "grep -i" | grep -i "$1")
#
#echo -e "\nfound processes"
#echo "$cmd"
#
#pids=$(echo "$cmd" | awk '{print $2}')


# alternative, as ps misses some processes!

files=$(find /proc/[0-9][0-9]* -name 'cmdline' 2>/dev/null | xargs grep -s --binary-files=text -l "$1" | grep -v self)




for i in $files; do
	pid=$(echo "$i" | sed 's/[^0-9]\+/ /g; s/ *$//; s/.* //; ')
	echo "$i: $pid"
	## cgclassify  -g cpu:/cpulimit $pid

	echo "$pid" >> $cgroup/cgroup.procs
done


