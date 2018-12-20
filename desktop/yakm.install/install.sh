#!/bin/bash

mkdir -p ~/software/

cd ~/software

python3 -m pip install --user python-xlib
git clone --depth 1 http://github.com/thomasrebele/yakm.git

mkdir -p ~/software/bin

ln -s $(realpath ~/software/yakm/yakm.py) ~/software/bin/yakm

