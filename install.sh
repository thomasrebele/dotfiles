#!/bin/bash

# default options
link_repo="false"
dotdir=$(realpath -s ~/.dotfiles2)

export DOTFILES=$dotdir

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
	export DOTFILES_ORIGIN=/home/tr/.dotfiles2
	if [ "$link_repo" = "true" ]; then
		ln -s $DOTFILES_ORIGIN $dotdir
	else
		git clone http://github.com/thomasrebele/dotfiles
		mv dotfiles $dotdir
	fi
fi

# dotfile repository created, now we can go into it
cd $dotdir

# import conditions
. $(pwd)/conditions.sh

# function for installing a category
install_category() (
	echo ""
	echo "installing $1 into $2"
	cd $1

	files() {
		/bin/ls -a -d -1 {.??,}*.symlink 
		/bin/ls -a -d -1 {.??,}*.dir 
		/bin/ls -a -d -1 install.sh 
		/bin/ls -a -d -1 {.??,}*.install
	}

	echo "list of actions"
	files 2> /dev/null | awk '{print "   " $0}'

	# symlinks
	for file in $(files 2> /dev/null); do
		case $file in

			.);;
			..);;

			# execute install.sh
			install.sh)
				file=$(realpath -s ./install.sh)
				echo looking for $file
				if [ -f $file ]; then
					echo executing $file
					. $file
				else
					echo "install.sh must be a file"
				fi
				;;

			# create symlink files
			*.symlink) 
				filename=${file%".symlink"}
				src=$(realpath -s $file)
				dst=$(realpath -s $2/$filename)
				if [ ! -L $dst ]; then

					# TODO: provide an option --force?
					if [ -e $dst ]; then
						rm -rf $dst
					fi

					echo "installing $filename ($dst -> $src)"
					ln -s $src  $dst
				fi			
				;;

			# create dir files
			*.dir) 
				dirname=${file%".dir"}
				dst=$(realpath -s $2/$dirname)

				if [ ! -d $dst ]; then
					echo "creating directory $dst"
					mkdir $dst
				fi

				install_category $(realpath -s $file) $dst
				;;


			# install sub-categories
			*.install)
				file=$(realpath -s $file)
				if [ -d "$file" ]; then
					echo "install sub-category " $file
					install_category $file $2
				else
					echo "$file must be a directory"
				fi
				;;

			*)
				echo "ignoring $file"
				;;
		esac
	done
)

for category in $*
do
	echo "--------------------------------------------------------------------------------"
	echo applying $category configuration
	echo "--------------------------------------------------------------------------------"

	cd $dotdir
	install_category $(realpath -s $category) ~
done

echo "$0 finished"

