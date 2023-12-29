#!/bin/bash
# from https://android.stackexchange.com/questions/220442/obtaining-app-storage-details-via-adb

USRDIR=$(mktemp -d)
F_DISK_STATS="$USRDIR"/diskstats.txt
F_PKG_NAMES="$USRDIR"/package_names.txt
F_PKG_SIZE="$USRDIR"/app_pkg_sizes.txt
F_DAT_SIZE="$USRDIR"/app_data_sizes.txt
F_CACHE_SIZE="$USRDIR"/app_cache_sizes.txt

# ADVISE: do a check whether ADB is working fine or not
adb shell dumpsys diskstats > "$F_DISK_STATS"

# Separating data into relevant named files
sed -n '/Package Names:/p' "$F_DISK_STATS" | sed -e 's/,/\n/g' -e 's/"//g' -e 's/.*\[//g' -e 's/\].*//g' > "$F_PKG_NAMES"
sed -n '/App Sizes:/p' "$F_DISK_STATS" | sed -e 's/,/\n/g' -e 's/.*\[//g' -e 's/\].*//g' > "$F_PKG_SIZE"
sed -n '/App Data Sizes:/p' "$F_DISK_STATS" | sed -e 's/,/\n/g' -e 's/.*\[//g' -e 's/\].*//g' > "$F_DAT_SIZE"
sed -n '/Cache Sizes:/p' "$F_DISK_STATS" | sed -e 's/,/\n/g' -e 's/.*\[//g' -e 's/\].*//g' > "$F_CACHE_SIZE"


# Printing package names and their sizes 
ttl_apps=$(wc -l "$F_PKG_NAMES" | cut -d ' ' -f1)
count=1
while [ $count -le $ttl_apps ]; do 
    pkg=$(sed -n "${count}p" "$F_PKG_NAMES")
    pkg_size=$(sed -n "${count}p" "$F_PKG_SIZE") 
    dat_size=$(sed -n "${count}p" "$F_DAT_SIZE")
    csh_size=$(sed -n "${count}p" "$F_CACHE_SIZE")
    sum=$((($pkg_size + $dat_size + $csh_size) / 1000000))
    echo -e "$pkg\t$sum\t$pkg_size\t$dat_size\t$csh_size"
    count=$(( $count + 1)); 
done | sort -n -k2
