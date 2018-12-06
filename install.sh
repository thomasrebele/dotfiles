#!/bin/bash

# default options
link_repo="false"
dotdir=$(realpath -s ~/.dotfiles2)

# command line arguments
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

# dotfile repository created, now we can go into it
cd $dotdir

# function for installing a category
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

	# create symlink files
	for file in $(ls -1a | grep ".symlink"); do
		filename=${file%".symlink"}
		src=$(realpath -s $file)
		dst=$(realpath -s $2/$filename)
		if [ ! -L $dst ]; then

			# TODO: provide an option --force?
			if [ -e $dst ]; then
				rm $dst
			fi

			echo "installing $filename ($dst -> $src)"
			ln -s $src  $dst
		fi
	done

	# create dir files
	for file in $(ls -1a | grep ".dir"); do
		dirname=${file%".dir"}
		dst=$(realpath -s $2/$dirname)

		if [ ! -d $dst ]; then
			echo "creating directory $dst"
			mkdir $dst
		fi

		install_category $file $dst
	done

}

for category in $*
do
	echo "--------------------------------------------------------------------------------"
	echo applying $category configuration
	echo "--------------------------------------------------------------------------------"

	cd $dotdir
	install_category $(realpath -s $category) ~
done

