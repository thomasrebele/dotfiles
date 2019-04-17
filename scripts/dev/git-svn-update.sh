#!/bin/bash

info() {
	echo 
	echo "--------------------"
	echo "- $@"
	echo "--------------------"
}

info stashing
git stash | tee /tmp/git-svn-update.log

info rebasing
git svn rebase

info applying stash if necessary
if ! grep -q "^No local changes to save$" /tmp/git-svn-update.log ; then
	git stash apply && git stash drop
fi

info finished

