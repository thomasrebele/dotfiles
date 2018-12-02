#!/bin/bash

dotdir=$(realpath ~/.dotfiles2)

# clone dotfile repository
if [ ! -e $dotdir ]; then
	cd ~/
	git clone http://github.com/thomasrebele/dotfiles
	mv dotfiles $dotdir
fi

install_category() {
	cd $1

	echo looking for $(pwd)/install.sh
	if [ -e install,sh ]; then
		./install.sh
	fi

}



for category in $*
do
	echo applying $category configuration

	current_dir=$(pwd)
	install_category $(realpath $category)
	cd $current_dir
done

