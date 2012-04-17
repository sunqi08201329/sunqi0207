index=1
total=0

until [ "$index" -gt "1000" ]
do
	x=`expr $index % 2`

	if [ "$x" -eq "0" ]
	then
		total=`expr $total + $index`
	fi

	index=`expr $index + 1`

	if [ "$index" -gt "100" ]
	then
	       break	
       else
	       continue
	fi
done

echo $total
