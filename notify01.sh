TYPE=$1
NAME=$2
STATE=$3
case $STATE in
"MASTER") route del default gw 192.168.154.1 dev ens192
exit 0
;;
"BACKUP") route add default gw 192.168.154.1 dev ens192
exit 0
;;
"FAULT") route add default gw 192.168.154.1 dev ens192
service haproxy restart
exit 0
;;
*) echo "unknown state"
exit 1
;;
esac