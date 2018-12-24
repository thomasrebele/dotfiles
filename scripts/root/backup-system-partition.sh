#!/bin/bash

echo "backup system disk (/dev/sda)"
echo "WARNING: kills all processes and remounts filesystem read-only"
echo "usage: <dstDir> <dstFilename>"

if [ "$#" -ne 2 ]; then
	echo "Illegal number of parameters"
	exit
fi

dstDir=$1
dstFile=$2

mkdir -p $1/empty-dir
#touch $1/$2

####apache2 apache-htcacheclean clamav-freshclam cron cups dbus exim4 lightdm network-manager networking ntp openvpn rsyslog smbd ssh tor vitualbox;

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
if [ $? -eq 0 ]; then
	cd $dstDir
	#mksquashfs empty-dir/ $dstFile -p 'sda_backup.img f 444 root root dd if=/dev/sda bs=32M conv=notrunc,fsync,noerror'
	ddrescue -d -p /dev/sda $dstFile $dstFile.logfile
	ddrescue -d -r3 -p /dev/sda $dstFile $dstFile.logfile
	# -p: preallocate file
	# -d: direct access
	# -r: retries

else
	echo "remount read-only failed"
fi

