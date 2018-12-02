#!/bin/bash

use_shell=/bin/zsh

if [ "$SHELL" != "$use_shell" ]; then
	echo changing shell to zsh
	chsh -s "$use_shell"
fi

if [ ! -e ~/.oh-my-zsh ]; then
	git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi



