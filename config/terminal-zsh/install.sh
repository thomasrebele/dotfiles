#!/bin/bash

if [ ! -e ~/software/oh-my-zsh ]; then
	github ~/software/ robbyrussell/oh-my-zsh
fi


if [ ! -e ~/software/zsh-git-prompt ]; then
	github ~/software/ zsh-git-prompt/zsh-git-prompt
	(
		cd ~/software/zsh-git-prompt
		./build.sh
	)
fi

if [ ! -e ~/software/fzf ]; then
	github ~/software/ junegunn/fzf
	(
		cd ~/software/fzf
		./install --key-bindings --completion --no-update-rc
	)
fi

