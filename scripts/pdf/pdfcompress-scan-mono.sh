#!/bin/bash



# command line arguments
while :; do
	case $1 in 
		--resize)
			shift
			resize_percent="$1"
			;;

		-?*)
			printf "Unknown option: %s\n" "$1" >&2
			exit
			;;
		*)
			break
	esac
	shift
done

if [ $# -lt 2 ]; then
	echo "usage: [options] <input> <output>"
	echo "options:"
	echo "  --resize <percent>"
	exit 1
fi

resize_percent=${resize_percent:-50}

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
	convert "$i" -resize $resize_percent% -colorspace gray  -quality 70 -density 100 -fill white -fuzz 80% -auto-level -depth 4 +opaque '#000000' "$i.jp2"; 
done

echo "convert to pdf"
convert *.jp2 out.pdf

echo "compress"
~/.dotfiles/scripts/pdf/pdfcompress.sh out.pdf "$OUTPUT"



