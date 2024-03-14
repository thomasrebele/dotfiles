#!/bin/bash

if [ "$3" == "" ]; then
	echo "usage: <branch> <source_path> <target_path>"
	exit
fi

info() {
	echo 
	echo "--------------------"
	echo "- $@"
	echo "--------------------"
}

is_svn() {
	git log --format=%b -n 1 "$1" | grep "git-svn-id"
}

SCRIPT_PATH="$(dirname `which $0`)"
source $SCRIPT_PATH/utils.sh


branch="$1"
source_path="$(realpath $2)"
target_path="$(realpath $3)"

(
	cd $source_path
	rev_map
	
	last_commit=$(git rev-parse $branch)

	test_commit="$last_commit"
	while ! is_svn $test_commit; do
		first_commit="$test_commit"
		test_commit=$(git rev-parse $test_commit^)
	done

	svn_rev=$(git svn find-rev $test_commit)
	base_commit="$test_commit"

	info "source commits $base_commit..$last_commit on svn rev $svn_rev"
	git log -v --format=full $base_commit..$last_commit | cat


	info "base commit $base_commit (svn rev $svn_rev)"
	git log -v --format=full -n 1 $base_commit | cat

	target_commit=""
	{
		cd $target_path;
		rev_map

		target_commit=$(find_commit $svn_rev)
		if [ -z "$target_commit" ]; then
			echo "ERROR: target commit for svn revision $svn_rev not found"
			exit 1
		fi

		info "target commit: $target_commit"
		git log --pretty=full -n 1 $target_commit | cat
	}

	cd $source_path

	echo $(pwd)
	read -p "Are you sure? (y/n) " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		info
		# do dangerous stuff

		tmp_branch="${branch}_$(date +%s)"
		(
			cd $target_path;

			for tmp in $branch $tmp_branch; do
				echo "creating branch '$tmp'"
				git checkout -b $tmp $target_commit 

				branch_commit=$(git rev-parse $branch)
				if [ "$target_commit" == "$branch_commit" ]; then
					echo "branch exists and has the right hash"
					break
				fi
			done

			if [ -z "$branch_commit" ]; then
				echo "ERROR: could not create branch"
				exit 1
			fi
		)
		echo "read"
		read _tmp_r

		echo "git format-patch" > /dev/stderr
		git format-patch -M --ignore-space-at-eol --stdout $base_commit..$last_commit | (
			cd $target_path;

			echo "git am" > /dev/stderr
			git am --reject --committer-date-is-author-date - || {
				echo "ERROR: could not apply patch for $0 $@" | tee -a git-move-branch.log
				exit
				git am --abort
			}

			if git branch -l | grep $tmp_branch; then
				echo "check result, compare $tmp_branch and $branch" > /dev/stderr
				
				if [ "$tmp_branch" != "$branch" ]; then
					final_commit1=$(git rev-parse "$tmp_branch")
					final_commit2=$(git rev-parse "$branch")

					if [ "$final_commit1" == "$final_commit2" ]; then
						git checkout $branch
						git branch -D "$tmp_branch"

						info "branch $branch was already moved"
					fi
				fi
			fi


		)
	fi
)

