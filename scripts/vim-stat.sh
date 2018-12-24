#!/bin/bash

dir=~/.vim-stat
mkdir -p $dir

hash=$(sha1sum ~/.vimrc | awk '{print $1}')
cp ~/.vimrc $dir/$hash-config

touch $dir/$hash-log $dir/$hash-keys
rm -rf $dir/current-log
ln -s $dir/$hash-log $dir/current-log

vim -w $dir/$hash-keys "$@"


