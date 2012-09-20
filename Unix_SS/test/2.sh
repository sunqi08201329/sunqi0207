#!/bin/bash
total=0
while [ $total < $# ]
do
total=`expr $total + 1`
token=$1
echo $token
shift 1
done
echo "$$"
echo "total num of token process is : $total"
