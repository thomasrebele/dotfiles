#!/bin/bash

# get firefox profile path, see http://askubuntu.com/a/354907
(
	cd ~/.mozilla/firefox/
	if [[ $(grep '\[Profile[^0]\]' profiles.ini) ]]
	then PROFPATH=$(tr < profiles.ini -s '\n' '|' | sed 's/\[Profile[0-9]\]/\x0/g; s/$/\x0/; s/.*\x0\([^\x0]*Default=1[^\x0]*\)\x0.*/\1/; s/.*Path=\([^|]*\)|.*/\1/')
	else PROFPATH=$(grep 'Path=' profiles.ini | sed 's/^Path=//')
	fi
	
	echo $(pwd)/$PROFPATH
)
