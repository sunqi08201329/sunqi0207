index=0
total=$#
sum=0

until [ "$index" -ge "$total" ]
do
	#echo $1

	sum=`expr "$sum" + "$1"`

	#echo $sum

	#echo $#
	shift

	index=`expr $index + 1`
done

echo $sum
