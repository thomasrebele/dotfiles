#!/bin/bash

mount -t tmpfs cgroup_root /sys/fs/cgroup
mkdir -p /sys/fs/cgroup/blkio
mount -t cgroup -o blkio none /sys/fs/cgroup/blkio
mkdir -p /sys/fs/cgroup/blkio/limit1M


mkdir -p /sys/fs/cgroup/blkio/limit1M/
size=1048576
size=104857600

echo "8:16 $size" > /sys/fs/cgroup/blkio/limit1M/blkio.throttle.write_bps_device
echo "8:16 $size" > /sys/fs/cgroup/blkio/limit1M/blkio.throttle.read_bps_device

# to limit a process: echo $PID > /sys/fs/cgroup/blkio/limit1M/tasks
