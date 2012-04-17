ip=`/sbin/ifconfig eth0 | grep "inet " | awk '{print $2}' | awk -F ":" '{print $2}'`

./app --host $ip
