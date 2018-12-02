#!/bin/bash

use_shell=/bin/zsh

if [ "$SHELL" != "$use_shell" ]; then
	echo changing shell to zsh
	chsh -s "$use_shell"
fi


