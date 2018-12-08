#!/bin/bash

xfconf-query -c keyboard-layout -p /Default/XkbLayout -n -s de,us -t string
xfconf-query -c keyboard-layout -p /Default/XkbVariant -n -s neo,intl -t string
xfconf-query -c keyboard-layout -p /Default/XkbDisable -n -s false -t bool


