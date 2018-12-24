#!/usr/bin/env python

import subprocess
import json
import re

#p=$(firefox-profile.sh)
#cat $p/addons.json | python -m json.tool | grep learnmoreURL | sed 's/.*\(http.*\)\/[?]src.*/\1/'

if __name__ == "__main__":
	p=subprocess.check_output("firefox-profile.sh", stderr=subprocess.STDOUT)[:-1]
	
	with open(p + "/addons.json") as file:    
		data = json.load(file)

	prefs = ""
	with open(p + "/prefs.js") as file:    
		for line in file:
			if line.startswith("user_pref(\"extensions.xpiState\""):
				prefs = line
				break
		# 
	prefs = re.sub(r"user_pref\(\".*\", \"(.*)\"\);", r"\1", prefs)
	prefs = prefs.replace("\\\"", "\"")
	prefs = json.loads(prefs)["app-profile"]
	map = {}
	for addon in prefs:
		#print(prefs[addon])
		map[addon] = prefs[addon]["e"]

	disabled = []
	for addon in data["addons"]:
		url = addon["learnmoreURL"]
		url = re.sub(r"\/\\?.src.*",r"", url)
	
		if map[addon["id"]]:
			print(url)
		else:
			disabled += [url]

	for addon in disabled:
		print("# " + addon)

	#print(json.dumps(prefs, indent=4))

