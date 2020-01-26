#!/bin/bash

# ensures that there are git-svn rev_maps for the SVN UUID that appears in the last commits

# find uuid
uuid=$(git log --pretty=full | grep git-svn-id | col -b | head -n 10 | awk '{print $3}' | uniq)

count=$(echo "$uuid" | wc -l)
if [ "$count" != 1 ]; then
	echo "Error: found $count UUIDs, expected exactly one!"
	exit 1
fi
echo "UUID: $uuid"

# find git dir
git_dir=$(git rev-parse   --git-common-dir 2> /dev/null)

# how to fix
fix() {
	uuid="$2"
	dir=$(dirname "$1")
	orig=$(basename "$1")
	link=".rev_map.$uuid"
	cd "$dir"
	if [ ! -L "$link" ]; then
		ln -s "$orig" "$link" 
	fi
}
export -f fix

# apply to all rev_maps
{
	cd $git_dir
	find -name '.rev_map.*' -exec bash -c "fix \"\$0\" '$uuid'" {} \;
}


