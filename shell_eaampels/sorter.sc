# Script is called sorter
# It sorts numbers in ascending order
function sort ( scores, num_elements, temp, i, j ) { 
	# temp, i, and j will be local and private, 
	# with an initial value of null.
	for( i = 2; i <= num_elements ; ++i ) {
		for ( j = i; scores [j-1] > scores[j]; --j ){
		   temp = scores[j]
		   scores[j] = scores[j-1]
		   scores[j-1] = temp
		}
	}
}
{for ( i = 1; i <= NF; i++)
	grades[i]=$i
sort(grades, NF)    # Two arguments are passed
for( j = 1; j <= NF; ++j )
	printf( "%d ", grades[j] )
	printf("\n")
}
