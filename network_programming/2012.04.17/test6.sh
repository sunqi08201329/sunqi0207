index=1
total=0

while [ "$index" -le "100" ]
do
	#total=`expr $total + $index`
	#let total=total+index	// bash support, dash not support
	let total+=index	// bash support, dash not support

	#index=`expr $index + 1`
	let index++		// bash support, dash not support
done

echo $total
