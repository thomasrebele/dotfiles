#!/bin/bash

sleep 20

killall ibus-daemon
ibus-daemon --xim &

