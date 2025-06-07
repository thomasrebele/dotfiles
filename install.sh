#!/usr/bin/env bash

# default options
link_repo="false"
dotdir=$(realpath -s ~/.dotfiles)

export DOTFILES=$dotdir

indent="   "

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

# clone repo from github
github() {
	local dir="$1"
	local repo="$2"
	local dest="$dir/${repo##*/}"
	if [ ! -e "$dest" ]; then
		git -C "$dir" clone --depth 1 "git@github.com:$repo"
	else
		echo "repository github.com/$repo exists in $dir"
	fi
}

# clone dotfile repository
if [ ! -e $dotdir ]; then
	cd ~/

	# TODO: provide this from outside
	export DOTFILES_ORIGIN=/home/tr/.dotfiles
	if [ "$link_repo" = "true" ]; then
		ln -s $DOTFILES_ORIGIN $dotdir
	else
		github ~ thomasrebele/dotfiles
		mv dotfiles $dotdir
	fi
fi

# dotfile repository created, now we can go into it
cd $dotdir

# import conditions
. $(pwd)/conditions.sh


handle_file() {
	# usage: <original-filename> <installation-dir> <still-to-parse> <prefix>
	local file="$1"
	local install_dir="$2"
	local to_parse="$3"
	local prefix="$4$indent"

	case $to_parse in

		.);;
		..);;

		# execute install.sh
		install.sh)
			local file=$(realpath -s ./install.sh)
			if [ -f $file ]; then
				echo "${prefix}${indent}executing $file"
				. $file
			else
				echo "${prefix}${indent}install.sh must be a file"
			fi
			;;

		*.copy)
			local filename=${to_parse%".copy"}
			local src=$(realpath -s $file)
			local dst=$(realpath -s $install_dir/$filename)
			
			if [ ! -e "$dst" ]; then
				echo "$prefix${indent}copying $src to $dst"
				cp $src $dst
			else
				echo "$prefix${indent}skipping copy because destination already exists: $dst"
			fi
			;;

		# create symlink files
		*.symlink) 
			local filename=${to_parse%".symlink"}
			local src=$(realpath -s $file)
			local dst=$(realpath -s $install_dir/$filename)


			if [ -L $dst ]; then
				# TODO: provide an option --force?
				# TODO: check destination
				if [ ! -e $dst ]; then
					# link is broken, so it's safe to remove
					rm -rf $dst
				fi
			fi


			if [ ! -e $dst ]; then
				echo "$prefix${indent}installing $filename ($dst -> $src)"
				ln -s $src  $dst
			fi
			;;

		# create dir files
		*.dir) 
			local dirname=${to_parse%".dir"}
			local dst=$(realpath -s $install_dir/$dirname)

			if [ ! -d $dst ]; then
				echo "$prefix${indent}creating directory $dst"
				mkdir $dst
			fi

			install_category $(realpath -s $file) $dst "$prefix"
			;;


		# install sub-categories
		*.install)
			local file=$(realpath -s $file)
			if [ -d "$file" ]; then
				echo "install sub-category " $file
				install_category $file $install_dir "$prefix"
			else
				echo "$file must be a directory"
			fi
			;;

		*.on.*|*.if.*)
			local condition=$(echo "$file" | sed 's/.*\.if\./if\./' | sed 's/.*\.on\./on\./')
			local to_parse=${file%.$condition}

			if check "$condition"; then
				handle_file $file $install_dir $to_parse $prefix
			else
				echo "$prefix${indent}ignored because $condition not fulfilled"
			fi
			;;

		*)
			echo "${prefix}ignoring $file"
			;;
	esac
}



# function for installing a category
install_category() (
	local category=$1
	local install_dir=$2
	local prefix="$3$indent"
	echo "${prefix}installing $category into $install_dir"

	if [ ! -d $category ]; then
		echo "${prefix}category $category not found in $(pwd)"
		return
	fi

	cd $category

	search() {
		find -maxdepth 1 -name "$@"
	}

	files() {
		{ 
			search '*.symlink'
			search '*.copy'
			search '*.dir'
			search install.sh 
			search '*.install'

			search '*' | grep -e "\.on\.\|\.if\."
		} | sed 's:^./::' | awk '!seen[$0]++'
	}

	### print list of actions for debugging
	# echo "${prefix}list of actions"
	# files 2> /dev/null | awk "{print \"$prefix$indent\" \$0}"
	# echo

	# symlinks
	for file in $(files 2> /dev/null); do
		echo "${prefix}* $file"
		handle_file $file $install_dir $file $prefix
	done
)


for category in $*
do
	echo ""
	echo "--------------------------------------------------------------------------------"
	echo applying $category configuration
	echo "--------------------------------------------------------------------------------"

	cd $dotdir
	install_category $(realpath -s $category) ~
done

echo "$0 finished"

