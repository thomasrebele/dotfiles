#!/bin/bash
# usage: <http(s)-url> <nameserver>
#
# Checks whether the server of an URL can be reached.
# In that case, outputs lines similar to
#    2011-01-01 12:23:34 URL:https://example.com/ [1256/1256] -> "-" [1]

host=$(echo "$1" | awk -F/ '{print $3}')
nameserver="$2"

dnsping() {
	ip=$(nslookup $host $nameserver | awk '/^Name:/ {FOUND=1} FOUND==1 && /^Address:/ { print $2}')
	echo $host $ip
}

while true; do
	printf '%s %s\n' "$(date --iso-8601=s)" "$1";
	dnsping
	stdbuf -i0 -o0 -e0 wget -nv -O- --tries=1 --timeout=5 "$1" 2> >(stdbuf -i0 -o0 -e0 grep -v -e Resolving -e "Giving up" -e "^$" -e "^Saving to" -e "^Length:" -e "^HTTP request sent" -e "^Reusing existing" -e "^Location:") > /dev/null
	# sleep until next full minute
	sleep $((60 - $(date +%S) ))
done
