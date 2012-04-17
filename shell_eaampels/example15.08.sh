n=5; name="Tom"
if [ $n > 0 ]    # Should be: if [ $n -gt 0 ]
then

if [ $n == 5 ]   # Should be: if [ $n -eq 5 ]
then

n++   # Should be: n=`expr $n + 1`

if [ "$name" == "Tom" ]      # Should be: if [ $name = "Tom" ]
