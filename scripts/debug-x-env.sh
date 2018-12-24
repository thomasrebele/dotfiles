#!/bin/bash

escape() {
	sed -e 's/\\/\\\\/g' -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

selected=$((echo "PATH=$PATH"; env) | dmenu -i | escape)

if [ ! -z "$selected" ]; then
	zenity --info --text "<span foreground='blue' font='20'>$selected</span>"
	#gxmessage --wrap "$selected"
fi

