#!/bin/bash

xfconf-query -c keyboard-layout -p /Default/XkbLayout -s de,us
xfconf-query -c keyboard-layout -p /Default/XkbVariant -s neo,intl


