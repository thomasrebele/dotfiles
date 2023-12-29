#!/bin/bash

if [ "$1" == "-r" ]; then
	shift 1
	adb shell cmd package install-existing "$1"
fi


adb shell cmd package uninstall --user 0 "$1"
adb shell cmd package uninstall --user 1 "$1"
adb shell cmd package uninstall --user 2 "$1"

adb shell cmd package uninstall "$1"

