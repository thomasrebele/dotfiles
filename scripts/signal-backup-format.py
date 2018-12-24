#!/usr/bin/env python


import sys

path = sys.argv[1]

# https://wiki.python.org/moin/EscapingXml
import html
html.unescape('Suzy &amp; John')

def field(line, field):
    body_start = line.index(field + "=") + len(field)+2
    body_end = line.index("\"", body_start)

    return line[body_start:body_end]


with open(path) as f:
    for line in f:
        print(field(line, "type") + "  " + html.unescape(field(line, "body")))


