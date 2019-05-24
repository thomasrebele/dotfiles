#!/bin/bash

# usage: <files...>
# creates a the n+1-th folder and moves the given files into it

MAX=$(find -regex './[0-9]+' -type d -printf '%f\n' | sort -n | tail -n 1)
DIR=$(echo $MAX + 1 | bc); 

mkdir ./$DIR; 
if mv "$@" ./$DIR; then
	echo "moved into $DIR"
else
	echo "nothing moved, undoing"
	mv $DIR/* .
	rm -d $DIR
fi
