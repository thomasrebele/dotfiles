#!/bin/bash

# Busybox http with directory listings

mkdir -p cgi-bin && trap 'rm -rf cgi-bin' INT && printf '#!/bin/bash\nprintf "Content-Type: text/html\\n\\n"; for f in ..${REQUEST_URI}*; do n="$(basename "$f")"; printf "<a href=\"%%s\">%%s</a><br/>" "$n" "$n"; done' > cgi-bin/index.cgi && chmod u+x cgi-bin/index.cgi && busybox httpd -c <(printf 'A:127.0.0.1\nD:*') -fvvvp 127.0.0.1:8001
