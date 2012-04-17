echo "Select a terminal type:  "
cat <<- ENDIT
	1) unix
	2) xterm
	3) sun
ENDIT
read choice
case "$choice" in
1) 	TERM=unix
	export TERM
	;;
2)  	TERM=xterm
	export TERM
	;;
3)	TERM=sun
	export TERM
	;;
esac
echo "TERM is $TERM."
