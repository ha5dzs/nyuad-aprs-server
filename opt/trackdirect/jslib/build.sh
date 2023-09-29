#!/bin/bash

INSTALLROOT=/opt/trackdirect
WWWROOT=/var/www/html

mkdir -p tmp

#
# Minimize and move to build dir
#
for file in $(find $INSTALLROOT/jslib/src/ -name '*.js')
do
    if [[ ${file} != *".min."* ]];then
        newFile="${file##*/}"
        newFile="tmp/${newFile//.js/}.min.js"
        echo "Processing $file -> $newFile"
        python -m jsmin $file > $newFile
        #cp $file $newFile
    else
        newFile="tmp/${file##*/}"
        echo "Processing $file -> $newFile"
        cp $file $newFile
    fi
done

#
# Create the full js file
#
cp tmp/trackdirect.min.js $WWWROOT/public/js/trackdirect.min.js
rm tmp/trackdirect.min.js
# Note that the order is important (may need to start adding digits in beginning of each js-file)
ls -vr tmp/*.js | xargs cat  >> $WWWROOT/public/js/trackdirect.min.js

#
# Remove temp dir
#
rm -R tmp

exit 0
