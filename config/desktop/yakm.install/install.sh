#!/bin/bash

mkdir -p ~/software/bin

python3 -m pip install --user python-xlib
github ~/software/ thomasrebele/yakm.git

ln -s $(realpath ~/software/yakm/yakm.py) ~/software/bin/yakm

