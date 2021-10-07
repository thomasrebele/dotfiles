#/bin/bash

sleep 3

bin=xmonad

if [ -f ~/.xmonad/xmonad-x86_64-linux ]; then
	bin=~/.xmonad/xmonad-x86_64-linux
fi


$bin --replace 2>&1 | tee ~/.xmonad.log 


