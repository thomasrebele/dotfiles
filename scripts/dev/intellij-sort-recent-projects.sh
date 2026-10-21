#!/usr/bin/env python

import xml.etree.ElementTree as ET
import sys

xml_file = sys.argv[1]

tree = ET.parse(xml_file)
root = tree.getroot()

for map_elem in root.findall(".//component/option/map"):
  entries = sorted(map_elem.findall("entry"), key=lambda e: e.get("key", ""), reverse=True)
  map_elem[:] = entries

tree.write(xml_file, encoding="utf-8", xml_declaration=True)
