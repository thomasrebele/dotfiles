#!/bin/bash

if [ $# -lt 2 ]; then
	echo "usage: <input> <output>"
	exit 1
fi

TMP=/tmp/pages-TODO
INPUT=$(realpath $1)
OUTPUT=$(realpath $2)

mkdir -p $TMP
cd $TMP
pdfimages "$INPUT" pages

for i in ./pages*.ppm; do 
	convert "$i" -resize 35% -colorspace gray  -quality 50 -density 100 -fill white -fuzz 80% -auto-level -depth 4 +opaque '#000000' "$i.jp2"; 
done

convert *.jp2 out.pdf

~/.dotfiles/scripts/pdf/pdfcompress.sh out.pdf "$OUTPUT"



