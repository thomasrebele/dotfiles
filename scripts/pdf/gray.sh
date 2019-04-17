#!/bin/bash

gs \
 -sDEVICE=pdfwrite \
 -dProcessColorModel=/DeviceGray \
 -dColorConversionStrategy=/Gray \
 -dPDFUseOldCMS=false \
 -dNOPAUSE \
 -dBATCH  \
 -o "${1/.pdf/-bw.pdf}" \
 -f "$1" \

