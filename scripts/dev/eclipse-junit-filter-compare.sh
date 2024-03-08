#!/bin/bash

# input <sorted method list1> <sorted method list2>

awk -v leftFile="$1" -v rightFile="$2" '
function abs(x) { 
    return x < 0 ? -x : x 
}

BEGIN {
	advanceLeft = 1
	advanceRight = 1
	hasLeft = 1
	hasRight = 1

	while(advanceLeft || advanceRight) {
		if(advanceLeft && hasLeft){
			advanceLeft = 0
			hasLeft = getline left < leftFile
		}
		if(advanceRight && hasRight) {
			advanceRight = 0
			hasRight = getline right < rightFile
		}

		if(hasLeft){
			split(left, l, "\t")
			methodL = l[1] "\t" l[2]
			timeL = l[3]
		}
		else {
			methodL = ""
			timeL = "none"
		}
		if(hasRight){
			split(right, r, "\t")
			methodR = r[1] "\t" r[2]
			timeR = r[3]
		}
		else {
			methodR = ""
			timeR = "none"
		}

		if(timeR == "none" || timeL == "none") {
			printLine = 1
		}
		else {
			timeDiff = timeR - timeL
			printLine = abs(timeDiff) > 0.3
		}


		if(methodL == methodR) {
			if(printLine) {
				print timeDiff "\t" timeL "\t" timeR "\t" methodL
			}
			advanceLeft = methodL != ""
			advanceRight = methodR != ""
		}
		else if(methodL < methodR){
			advanceLeft = 1
		}
		else {
			advanceRight = 1
		}

		if(methodL == "" && methodR == "") {
			break
		}
	}

}
'



