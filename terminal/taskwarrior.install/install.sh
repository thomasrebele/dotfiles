#!/bin/bash


# install z
if [ ! -e ~/software/vit  ]; then
	github ~/software/ thomasrebele/vit
	(
		cd ~/software/vit
		./configure
		make
	)
fi

if [ ! -e ~/software/bin/vit ]; then
	mkdir -p ~/software/bin
	ln -s ~/software/vit/vit ~/software/bin/vit
fi


