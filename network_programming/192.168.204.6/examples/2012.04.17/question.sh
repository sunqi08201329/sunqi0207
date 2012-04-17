echo -n "Continue[y/n]?"

read answer

case "$answer" in
  y|Y)
  	echo "continue"
	;;
  [yY][eE][sS])
  	echo "continue"
  	;;
  n|N)
  	echo "exit."
	;;
  [nN][oO])
  	echo "exit."
	;;
esac
