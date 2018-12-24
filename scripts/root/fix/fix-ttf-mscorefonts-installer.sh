DIR=/tmp/mscorefonts/

mkdir -p $DIR

cd $DIR
grep Url: /usr/share/package-data-downloads/ttf-mscorefonts-installer | awk '{print $2}' | xargs -n 1 wget
cd -

echo "run "
echo "   dpkg-reconfigure ttf-mscorefonts-installer"
echo "and specify $DIR as fonts folder"
echo "you need to delete $DIR afterwards"


