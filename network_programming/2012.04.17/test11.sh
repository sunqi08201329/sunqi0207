index=0
total=$#
sum=0

until [ "$index" -ge "$total" ]
do
	echo ${$index}

	#sum=`expr "$sum" + "$1"`

	#echo $sum

	#echo $#
	#shift

	index=`expr $index + 1`
done
