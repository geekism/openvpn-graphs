#!/bin/bash

for line in $(cat /etc/openvpn/ipp.txt);do
CLIENT=$(echo $line|cut -d',' -f1)
VPN_IP=$(echo $line|cut -d',' -f2)
echo "
iptables -N ${CLIENT}_IN
iptables -N ${CLIENT}_OUT
iptables -A ${CLIENT}_IN -j RETURN
iptables -A ${CLIENT}_OUT -j RETURN
iptables -I ${CLIENT}_IN -d ${VPN_IP}
iptables -I ${CLIENT}_OUT -s ${VPN_IP}
iptables -A FORWARD -j ${CLIENT}_in
iptables -A FORWARD -j ${CLIENT}_out
"

echo "OUTGOING=\$(iptables -v -x -L ${CLIENT}_out|grep -E \"RETURN\"|cut -d' ' -f5)"
echo "INCOMING=\$(iptables -v -x -L ${CLIENT}_in|grep -E \"10\"|cut -d' ' -f5)"

done

