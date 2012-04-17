#!/bin/sh

if [ $# -ne 1 ]
  then
    echo "Usage: $0 -l | -u"
    exit 1
fi

if [ $1 != "-l" -a $1 != "-u" ]
  then
    echo "Usage: $0 -l | -u"
    exit 1
fi

if [ $1 = "-l" ]
  then
    for file in *
      do
        #echo "Processing $file ..."
	#targetFile=`expr "+++$file":'+++\(.*\)'|tr '[A-Z]''[a-z]'`
	targetFile=`expr $file : '\(.*\)' | tr '[A-Z]' '[a-z]'`
	echo "$file -> $targetFile"
	mv $file $targetFile
      done
  else
    for file in *
      do
        #echo "Processing $file ..."
	targetFile=`expr $file : '\(.*\)' | tr '[a-z]' '[A-Z]'`
	echo "$file -> $targetFile"
	mv $file $targetFile
      done
fi
