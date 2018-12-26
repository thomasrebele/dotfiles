#!/bin/bash

if [ ! -e ~/software/oh-my-zsh ]; then
	github ~/software/ robbyrussell/oh-my-zsh
fi


if [ ! -e ~/software/zsh-git-prompt ]; then
	github ~/software/ thomasrebele/zsh-git-prompt
	(
		cd ~/software/zsh-git-prompt
		./build.sh
	)
fi

