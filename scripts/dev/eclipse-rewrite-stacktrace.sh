#!/bin/bash

# use this script to transform eclipse debug stack trace to the format of "java stack trace console"
# in the console view you can then use the hyperlink function of Eclipse for quicker navigation


awk '
/line: / {
	fn_path = $0
	gsub(/^[ \t]+/, "", fn_path);
	gsub(/\([^)]*\)/, "", fn_path);
	gsub(/ line:.*/, "", fn_path);

	match(fn_path, ".*\\.([^.]*)\\.[^.]*", class);

	match($0, ".*line: ([0-9]+).*", line);
	link = "    at " fn_path "(" class[1] ".java:" line[1] ")"
	# printf "%40s%s\n", link, $0
	print link

}

!/line: / {
	print $0
}
' $1


