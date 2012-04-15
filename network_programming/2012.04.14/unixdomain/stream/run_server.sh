prog="./server"
sock_file="1.sock"
backlog=10

if [ -S "$sock_file" ]
	then
		echo "socket file exists, remove it."
		rm -f "$sock_file"
fi

"$prog" "$sock_file" "$backlog"
