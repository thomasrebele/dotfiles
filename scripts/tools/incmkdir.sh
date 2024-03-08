#!/bin/bash

# creates the n+1-th folder

MAX=$(find -regex './[0-9]+' -type d -printf '%f\n' | sort -n | tail -n 1 || echo 0)

if [ -z "$MAX" ]; then
	MAX=0
fi

DIR=$(echo $MAX + 1 | bc);

mkdir ./$DIR;

echo $DIR
