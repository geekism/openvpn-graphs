#!/bin/bash
INDEX_PATH="/srv/beyondhd.me"

for line in $(cat /etc/openvpn/ipp.txt);do
CLIENT=$(echo $line|cut -d',' -f1)
VPN_IP=$(echo $line|cut -d',' -f2)
echo "
	/sbin/iptables -N ${CLIENT}_IN
	/sbin/iptables -N ${CLIENT}_OUT
	/sbin/iptables -A ${CLIENT}_IN -i tun+ -s ${VPN_IP}
	/sbin/iptables -A ${CLIENT}_OUT -o tun+ -d ${VPN_IP}
	/sbin/iptables -A FORWARD -i tun+ -s ${VPN_IP} -j ${CLIENT}_IN
	/sbin/iptables -A FORWARD -o tun+ -d ${VPN_IP} -j ${CLIENT}_OUT
" >> /etc/vpngraph.sh
bash /etc/vpngraph.sh
echo "Verifing the tables are added"
/sbin/iptables -xvnL|grep ${CLIENT}

vpngraph="*/5 * * * * ${INDEX_PATH}/vpn.pl ${CLIENT} >/dev/null 2>&1"
crontab -l > /tmp/cron.tmp
echo "${vpngraph}" >> /tmp/cron.tmp
crontab /tmp/cron.tmp
sed -i "s/eth0/vpn-${CLIENT}\",\"eth0/g" ${INDEX_PATH}/index.cgi
done

