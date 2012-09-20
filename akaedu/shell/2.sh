#! /bin/sh
echo "is it moring? please answer yes or no."
read YES_OR_NO
if [ "$YES_OR_NO" = "yes" ]
then
	echo "good morning"
elif [ "$YES_OR_NO" = "no" ]; then #command on a line use ; split
	echo "good afternoon"
else
	echo "sorry, $YES_OR_NO not recognized. Enter yes or no."
	exit 1
fi
exit 0

