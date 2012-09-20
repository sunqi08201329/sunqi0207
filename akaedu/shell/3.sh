#! /bin/sh
echo "Is it morning? please answer yes or no."
read YES_OR_NO
case "$YES_OR_NO" in (yes|y|Y|YES)
echo "Good morning";;
[nN][oO])
echo "Good afternoon";;
*)
echo "sorry, $YES_OR_NO not recognized. Enter yes or no."
exit 1;;
esac
exit 0
