
cmd="wget -O- http://www.mv-buchdorf.de/files/tr/my_stories.csv" 

if [ ! "$1" == "" ]; then

	cmd="cat $1"
fi

#$cmd | perl -MText::CSV -E '$csv = Text::CSV->new({binary=>1});while ($row = $csv->getline(STDIN)) {say $row->[0]}' | awk 'BEGIN{ rtk1=0; p=0} $1<=2042{rtk1+=1} $1!=p+1{print p+1"-"$1-1}{p=$1} END{ print "count of RTK1: " rtk1 "\nmissing: " (2042-rtk1)}'
$cmd | perl -MText::CSV -E '$csv = Text::CSV->new({binary=>1});while ($row = $csv->getline(STDIN)) {say $row->[0]}' | tail -n+2 | awk 'BEGIN{ rtk1=0; p=0} $1<=2042{rtk1+=1} $1!=p+1{print p+1"-"$1-1}{p=$1} $1>3030{exit} END{ print "count of RTK1: " rtk1 "\nmissing: " (2042-rtk1)}' | column


# RTK indices 1-3030
# Unicode indices 19968-
