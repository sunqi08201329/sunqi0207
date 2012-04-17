#files=`ls`
files=$(ls)	# http://tldp.org/LDP/abs/html/commandsub.html

for filename in $files
do
	echo $filename
done
