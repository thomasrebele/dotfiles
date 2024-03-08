#!/bin/bash

# CoPy Relative
# usage: <src-dir> <dst-dir> <files...>

src="$1"
dst="$2"
shift 2


if [ "$src" == "" ]; then
	echo "src dir may not be empty"
	exit 1
fi

if [ "$dst" == "" ]; then
	echo "dst dir may not be empty"
	exit 1
fi

for i in "$@"
do
	dir="$dst/$(dirname $i)"
	if [ ! -d "$dir" ]; then
		mkdir "$dir"
	fi
	echo cp -r "$src/$i" "$dst/$i"
	cp -r "$src/$i" "$dst/$i"
done

