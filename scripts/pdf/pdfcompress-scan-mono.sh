#!/bin/bash

if [ $# -lt 2 ]; then
	echo "usage: <input> <output>"
	exit 1
fi

echo "input: $1"
TMP=/tmp/pages-TODO
INPUT="$(realpath "$1")"
echo "input: $INPUT"
OUTPUT="$(realpath "$2")"

mkdir -p $TMP
cd $TMP
echo "splitting"
pdfimages "$INPUT" pages

echo "mono"
for i in ./pages*.ppm; do 
	convert "$i" -resize 50% -colorspace gray  -quality 70 -density 100 -fill white -fuzz 80% -auto-level -depth 4 +opaque '#000000' "$i.jp2"; 
done

echo "convert to pdf"
convert *.jp2 out.pdf

echo "compress"
~/.dotfiles/scripts/pdf/pdfcompress.sh out.pdf "$OUTPUT"



