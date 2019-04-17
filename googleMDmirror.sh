#!/bin/bash
  
#make storage dir

mkdir google
cd google

#download mirror of Material Design site

wget --mirror --convert-links --adjust-extension --page-requisites --no-parent --span-hosts -Dstorage.googleapis.com,material.google.com https://material.google.com

#find location of missing mp4 files and parse

grep -r 'mp4' material.google.com/ | grep 'http' > output

sed -i 's/[^"]*"//' output

sed -i 's/\.mp4.*/\.mp4/' output

cp output srcfiles

sed 's/https:\/\///' output > dstfiles

#build curl video download script

sed -i 's/^/curl /' srcfiles
sed -i 's/^/--create-dirs -o /' dstfiles

echo "#!/bin/bash" > getMDvids.sh

paste -d ' ' srcfiles dstfiles >> getMDvids.sh

chmod 755 getMDvids.sh

#execute curl video download script

./getMDvids.sh

#locate and parse references to old locations

grep -r 'https://material-design.' material.google.com/ | grep 'mp4' > list

sed -i 's/\:[^:]*$//' list
sed -i 's/\:[^:]*$//' list

sort -u list > listsort

#build site modification script

tmp=$(wc -l <listsort)
for ((i=0; i<$tmp; i++))
do
        echo "sed -i 's/https:\/\/mat/\.\.\/mat/'" >> cmd
done

echo "#!/bin/bash" > modifyMDsite.sh

paste -d ' ' cmd listsort >> modifyMDsite.sh

chmod 755 modifyMDsite.sh

#execute site modification script

./modifyMDsite.sh

#cleanup

rm output srcfiles dstfiles getMDvids.sh list listsort cmd modifyMDsite.sh

#prepare to create TAR

cp -rf storage.googleapis.com/ material.google.com/
cp -rf material-design.storage.googleapis.com/ material.google.com/

cd ..

#create TAR

tar -czvf googleMD.tar.gz google/

#finish cleanup

rm -rf google/

#end script
