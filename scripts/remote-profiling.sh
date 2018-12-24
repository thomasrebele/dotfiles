#!/bin/bash

echo "1.) start ssh tunnel: ssh -v -N -D 9696 <host>"
echo "2.) start visualvm (new version, not jvisualvm)"
echo "3.) add socks proxy localhost:9696"

echo ""
echo "for JMX connections:"
echo "4.) start java application: java -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9696 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false <...>"
echo "5.) connect to JMX in visualvm"

echo "I'll run jstatd"

jstatd -J-Djava.security.policy=jstatd.all.policy -J-Djava.rmi.server.hostname=139.19.52.81  -J-Djava.rmi.server.logCalltrue
