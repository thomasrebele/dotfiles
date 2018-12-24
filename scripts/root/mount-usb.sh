
mount $1 usb
cd usb
mount -t devtmpfs dev dev
mount -t devpts devpts dev/pts
mount -t proc proc proc
mount -t sysfs sysfs sys
chroot .
