#!/bin/bash

# ultrastar txt input file
input="$1"

if [ "$input" == "" ]; then
	echo "missing argument"
	exit
fi

if [ ! -e "$input.original" ]; then
	cp "$input" "$input.original"
fi

# search video info
video=$(cat "$input" | grep -m 1 "^#VIDEO")

# parsing
printf '%s%s\n' "parsing video line: " "${video}"
echo ""

tabsep=$(printf '%s\n' "${video}" | sed 's/:v=/\tyt\tv=/;  s/,co=/\tco\t/; s/,bg=/\tbg\t/; ')

IFS=$'\t'; read -ra sep <<< "${tabsep}"
yt=""
co=""
bg=""

i=-1
while ((i<${#sep[@]}));
do
	((i+=1))

	it="${sep[$i]}"

	if [ "$it" == "yt" ]; then
		((i+=1))
		yt="${sep[$i]}"
		printf '%s\n' "yt: $yt"
		continue
	fi
	if [ "$it" == "co" ]; then
		((i+=1))
		co="${sep[$i]}"
		printf '%s\n' "co: $co"
		continue
	fi
	if [ "$it" == "bg" ]; then
		((i+=1))
		bg="${sep[$i]}"
		printf '%s\n' "bg: $bg"
		continue
	fi

done;

echo "[press key to continue]"
read

### download cover
co_filename=$(basename "${co}")
extension=$([[ "$co_filename" = *.* ]] && echo ".${co_filename##*.}" || echo '')
co_target="cover.$extension"
curl --output $co_target "$co" 



