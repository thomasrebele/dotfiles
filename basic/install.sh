#!/bin/bash


# install z
if [ ! -e ~/software/z  ]; then
	github ~/software/ rupa/z
	touch ~/.z
fi

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



