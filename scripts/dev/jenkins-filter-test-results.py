#!/usr/bin/env python

import xml.etree.ElementTree as ET
import sys
import re

xml_file = 'TODO.xml'

tree = ET.parse(xml_file)
root = tree.getroot()

def remove_one_child(el, tag):
    child = el.find(tag)
    if not child is None:
        el.remove(child)

def ignore_case(case):
    detail_el = case.find("errorDetails")
    if detail_el is None: return False
    detail = detail_el.text.split('\n')

    ignore = True
    because = ""
    for line in detail:
        if ignore_case_detail_line(line):
            continue
        because += "\n  '" + line + "'"
        ignore = False

    if not ignore:
        print("needed: " + str(because))

    return ignore

def ignore_case_detail_line(line):
    if line in [""]:
        return True
    if re.fullmatch(r'.*SomeException.*', line) is not None:
        return True
    return False

c_suits = 0
c_cases = {}
for suite in root.findall(".//suite"):
    c_suits += 1

    cases = 0
    for case in suite.findall("case"):
        status = case.find("status").text
        if not status in c_cases:
            c_cases[status] = 0
        c_cases[status] = 1 + c_cases[status]

        if status == "PASSED" or status == "SKIPPED":
            suite.remove(case)
            continue

        
        if ignore_case(case):
            suite.remove(case)
            continue

        cases += 1

        remove_one_child(case, "stderr")

    if cases == 0:
        root.remove(suite)

print("suits: " + str(c_suits))
print("cases: " + str(c_cases))

tree.write("out-" + xml_file, encoding="utf-8", xml_declaration=True)
