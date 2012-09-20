#! /bin/sh
if [ -f 1 ]
then
	mv 1 $1
else
	touch 1
fi
vim 1
