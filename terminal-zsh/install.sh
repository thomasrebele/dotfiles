#!/bin/bash

if [ ! -e ~/.oh-my-zsh ]; then
	git clone https://github.com/robbyrussell/oh-my-zsh.git --depth 1 ~/.oh-my-zsh
fi


if [ ! -e ~/software/zsh-git-prompt ]; then
	git clone git://github.com/thomasrebele/zsh-git-prompt --depth 1 ~/software/zsh-git-prompt
	(
		cd ~/software/zsh-git-prompt
		./build.sh
	)
fi

