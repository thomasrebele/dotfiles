#!/bin/bash

if [ $# -lt 1 ]; then
	echo "usage: <dir> [<command>]"
	exit 1
fi

dir=$1
shift 1
args=$@

if [ "$args" == "" ]; then args="zsh"; fi

echo "starting sandbox"

cat >$dir/.zshrc <<BLOCK
echo "oh-my-zsh not available"

setopt INC_APPEND_HISTORY 
HISTSIZE=200000                                # this zsh's history size
SAVEHIST=100000                                     # never touch HISTFILE
HISTFILE=~/.zshhistory                         # history file name
zmodload zsh/datetime                          # needed for EPOCHSECONDS

RED='\033[0;31m'
NC='\033[0m'
PROMPT='** %F{cyan}%n@%m %F{yellow}SANDBOX%f $time %T %~ **$ '

bindkey -v
export KEYTIMEOUT=1

bindkey '^?' backward-delete-char
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^R' history-incremental-search-backward
BLOCK

firejail --profile=$HOME/.config/firejail/untrusted.profile --private=$dir $args
