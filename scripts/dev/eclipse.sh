#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo $DIR > /tmp/eclipse.log
export GTK2_RC_FILES=$DIR/.gtkrc-2.0
export SWT_GTK3=0

cd $DIR

echo $GTK2_RC_FILES >> /tmp/eclipse.log
nohup $DIR/eclipse $* > /dev/null &
