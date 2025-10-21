#!/usr/bin/env bash

getVersion() {
	content=$(wget http://keepass.info/download.html -q -O -)
	versionline=$(echo "$content" | grep -A 5 "Here you can download" | tail -n 5)
	versioncheck=$(echo "$versionline" | grep "KeePass")

	if [ "$versioncheck" == "" ]; then
		echo "Keepass version not found, got line: $versionline";
		return -1;
	fi


	echo "$versioncheck" | tr '\n' ' ' | tr '\r' ' ' | sed 's/.*KeePass \([^<]*\)<.*/\1/'
}

keepass_update() {
	version=$(getVersion)
	if [ "$?" != 0 -o "$version" == "" ]; then
		echo "didn't find version"
		echo "$version"
		return -1;
	fi

	echo "- updating to version $version"
	basedir=~/software/keepass
	dirname=KeePass-$version
	dstdir=$basedir/$dirname
	
	updateKeepass() {
		timestamp=$(date +"%s")
	
		if [ -f $dstdir/KeePass.exe ]; then
			echo "- keepass already up to date"
			return 1;
		else
			echo "not found"
		fi
	
		url="http://downloads.sourceforge.net/project/keepass/KeePass%202.x/$version/KeePass-$version.zip?r=&ts=$timestamp&use_mirror=vorboss"
		(
			mkdir -p $dstdir
			cd $dstdir
			wget --output-document=KeePass.zip "$url"
			unzip KeePass.zip
			rm KeePass.zip
			cd $basedir
			rm default
			ln -s $dirname default
		)
		echo "- updated keepass"
	}
	
	updateKeepassRPC(){
		url="https://github.com/kee-org/keepassrpc/releases"
		wget --output-document=/tmp/keepassrpc.html "$url"

		content=$(wget "$url" -q -O -)
		versionline=$(echo "$content" | grep -m 1 "plgx" )
		link="https://github.com/$(echo "$versionline" | sed 's/.*href="\([^"]*\)".*/\1/')"
		
		echo "downloading $link to $dstdir/KeePassRPC.plgx"
		wget -N --output-document=$dstdir/KeePassRPC.plgx $link
	}
	
	updateKeepass
	updateKeepassRPC

}

keepass_update
