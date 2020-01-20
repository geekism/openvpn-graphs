#!/bin/bash
INDEX_PATH="/srv/beyondhd.me"

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
iptables -A FORWARD -j ${CLIENT}_IN
iptables -A FORWARD -j ${CLIENT}_OUT
" >> /etc/vpngraph.sh
bash /etc/vpngraph.sh

OUTGOING=$(iptables -v -x -L ${CLIENT}_OUT|grep -E "RETURN"|cut -d' ' -f5)
INCOMING=$(iptables -v -x -L ${CLIENT}_IN|grep -E "10"|cut -d' ' -f5)
echo "Verifing the tables are added"
echo "Outgoing: $OUTGOING/bytes"
echo "Incoming: $INCOMING/bytes"

vpngraph="*/5 * * * * ${INDEX_PATH}/vpn.pl ${CLIENT} >/dev/null 2>&1"
crontab -l > /tmp/cron.tmp
echo "${vpngraph}" >> /tmp/cron.tmp
crontab /tmp/cron.tmp
sed -i "s/eth0/vpn-${CLIENT}\",\"eth0/g" ${INDEX_PATH}/index.cgi
done

