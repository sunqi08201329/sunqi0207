ifconfig_cmd="/sbin/ifconfig"
route_cmd="/sbin/route"
interface="eth0"
ip_address="192.168.24.6"
netmask="255.255.255.0"
gateway="192.168.204.1"

$ifconfig_cmd $interface $ip_address netmask $netmask

$route_cmd add default gw $gateway

cat "nameserver 8.8.8.8" > /etc/resolv.conf
cat "nameserver 8.8.4.4" >> /etc/resolv.conf

echo "1" > /proc/sys/net/ipv4/ip_forward

service iptables restart
