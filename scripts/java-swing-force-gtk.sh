#!/bin/bash

_JAVA_OPTIONS="-Dswing.systemlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dawt.useSystemAAFontSettings=on $_JAVA_OPTIONS" "$@"
