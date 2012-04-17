name="Tom"
n=5
if [ $name == [Tt]om ]      # Should be: if [[ $name == [Tt]om ]]
[[ n+=5 ]]  # Should be: (( n+=5 ))
