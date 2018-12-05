#!/bin/bash

# command line arguments

echo "installing dotfiles"

link_repo="false"

while :; do
	echo "parse $1"
	case $1 in 
		--link-repo)
			link_repo="true"
			;;
		-?*)
			printf "Unknown option: %s\n" "$1" >&2
			;;
		*)
			break
	esac
	shift
done

echo "done parsing, link_repo=$link_repo"

dotdir=$(realpath -s ~/.dotfiles2)

echo "setting up dotfiles for user $(whoami) at $dotdir"

# clone dotfile repository
if [ ! -e $dotdir ]; then
	cd ~/

	# TODO: provide this from outside
	export DOTFILES_REPO=/home/tr/.dotfiles2
	if [ "$link_repo" = "true" ]; then
		ln -s $DOTFILES_REPO $dotdir
	else
		git clone http://github.com/thomasrebele/dotfiles
		mv dotfiles $dotdir
	fi
fi

cd $dotdir

install_category() {
	cd $1

	# execute install.sh
	file=$(realpath -s ./install.sh)
	echo looking for $file
	if [ -f $file ]; then
		echo executing $file
		. $file
	else
		echo "doesn't exist"
	fi

	# symlink files

	for file in $(ls -1a | grep ".symlink"); do
		filename=${file%".symlink"}
		src=$(realpath -s $file)
		dst=~/$(realpath --relative-to="$(pwd)" $filename)
		if [ ! -L $dst ]; then

			if [ -e $dst ]; then
				rm $dst
			fi

			echo "installing $filename ($src -> $dst)"
			ln -s $src  $dst
		fi
	done

}



for category in $*
do
	echo "--------------------------------------------------------------------------------"
	echo applying $category configuration
	echo "--------------------------------------------------------------------------------"

	cd $dotdir
	install_category $(realpath -s $category)
done

