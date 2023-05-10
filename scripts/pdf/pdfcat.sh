#!/bin/bash

# usage: <in-pdf> <out-pdf> <pages...>

src="$1"
dst="$2"
shift 2

pdftk "$src" cat "$@" output "$dst"

