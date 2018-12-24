#!/bin/bash


# install z
mkdir -p ~/software/z
git -C ~/software/ clone git://github.com/rupa/z
touch ~/.z

# set shell
ZSH=/bin/zsh
BASH=/bin/bash
if [ "$SHELL" != "$ZSH" ]; then
	if [ -h ~/.zshrc ]; then
		echo changing shell to zsh
		chsh -s "$ZSH"
	else
		echo "~/.zshrc not found, changing shell to bash"
		chsh -s "$BASH"
	fi
fi



