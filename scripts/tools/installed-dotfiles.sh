#!/bin/bash

find -L ~ -xtype l -print0 | xargs -0 ls -plah | grep -- "->.*dotfiles" | sed 's/^[^/]*//'
