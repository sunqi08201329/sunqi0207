for i in {1..9}
do
	for j in {1..9}
	do
		value=`expr $i \* $j`

		if [ $value -le "9" ]
		then
			echo -n "   $value"
		else
			echo -n "  $value"
		fi

		#echo -n $value
	done

	echo 
done
