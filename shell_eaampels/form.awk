# form.awk is an awk script that requires access to 2 files: The
# first file is called "form.letter." This file contains the
# format for a form letter. The awk script uses another file,
# "data.form," as its input file. This file contains the
# information that will be substituted into the form letters in
# the place of the numbers preceded by pound signs. Today's date
# is substituted in the place of "@date" in "form.letter."
BEGIN{ FS=":"; n=1
while(getline < "form.letter" >  0)
 	form[n++] = $0   # Store lines from form.letter in an array
"date" | getline d; split(d, today, " ")
	# Output of date is Fri Mar 2 14:35:50   PST 2004
thisday=today[2]". "today[3]", "today[6]
}
{ for( i = 1; i < n; i++ ){
	temp=form[i]
	for ( j = 1; j <=NF; j++ ){
	gsub("@date", thisday, temp)
		gsub("#" j, $j , temp )
	}
print temp
}
}
