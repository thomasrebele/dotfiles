#!/usr/bin/env bash

if [ $# -lt 2 ]; then
	echo "usage: <input> <output>"
	exit 1
fi

# TODO:
# compress with screen
# compress several times

# reduce DPI:  -dColorImageResolution=/Bicubic -dColorImageResolution=141
# similar options for gray / mono images

gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$2" "$1"


