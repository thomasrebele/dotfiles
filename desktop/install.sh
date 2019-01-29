#!/bin/bash

github ~/software/ phillipberndt/autorandr
github ~/software/ jceb/srandrd

if [ -d ~/software/srandrd ]; then
	(
		cd ~/software/srandrd
		make
	)
fi


