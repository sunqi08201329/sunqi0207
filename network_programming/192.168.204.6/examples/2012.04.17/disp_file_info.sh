#files=`find . -name "*" -type f`
files=`ls -Ql | awk -F "\"" '{print $2}'`

IFS_BACKUP="$IFS"

IFS="\n"

for filename in $files
do
	#echo "$filename"
	file "$filename"
done

IFS="$IFS_BACKUP"
