#!/bin/bash
a=0
for token in $*
do 
a=$((a+1))
echo $token
done
echo "num args is : $a"
