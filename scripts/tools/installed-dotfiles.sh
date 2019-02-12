#!/bin/bash

if [ "$target" = "" ]; then
	target="/.dotfiles/"
fi


find ~ -type l -print0 | xargs -0 ls -plah | grep -- "->.*$target" | sed 's/^[^/]*//'
