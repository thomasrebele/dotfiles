#!/bin/bash

# original: http://stackoverflow.com/a/29032397/168874
# improved: https://gist.github.com/gene1wood/3b4b37d5a438871b8876

resize_images() {
	find "$1" \( -iname "*.png" -o -iname "*.gif" \) -exec sh -c "expr \$(identify -format \"%h\" {}) \< 32 > /dev/null" \; -exec convert "{}" -resize 400% {} \; -printf "%f resized\n" | grep '.'
}


for J in *.jar
do
    d="`mktemp --directory`"
    trap 'rm -rf "$d"' EXIT
    f="`readlink -f \"$J\"`"

    echo "Extracting $J..."
    unzip -q "$f" -d "$d"

    echo "Processing images in $J..."
    if resize_images "$d"; then

        echo "Compressing $J..."
        #mv -f "$f" "$f.`date +%Y%m%d%H%M%S`.bak"
        pushd "$d" >/dev/null
        zip -qr "$f" .
        popd >/dev/null
    fi

    rm -rf "$d"
done

echo "Processing all images outside of jars..."
resize_images "."


