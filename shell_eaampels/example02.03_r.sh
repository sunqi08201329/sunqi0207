#!/bin/sh 
#file=./example02.03
echo "test file is" $1
if [ -f $1 ]
  then
	echo file exists
 
if [ -d $1 ] 
  then
 	 echo file is a directory
  else
  	echo file is not a directoy
fi

if [ -s $1 ] 
  then
	 echo file is nonzero length 
  else
  	echo file is zero length
fi

if [ -r $1 -a -w $1 ]
  then
	 echo file is readable and writeable
fi
else
	echo file is not exist
fi
