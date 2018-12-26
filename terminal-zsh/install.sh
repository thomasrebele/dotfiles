#!/bin/bash

if [ ! -e ~/.oh-my-zsh ]; then
	github ~/ robbyrussell/oh-my-zsh
fi


if [ ! -e ~/software/zsh-git-prompt ]; then
	github ~/software/ thomasrebele/zsh-git-prompt
	(
		cd ~/software/zsh-git-prompt
		./build.sh
	)
fi

