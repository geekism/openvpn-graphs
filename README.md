# openvpn graphs

guide is located:

https://blog.justla.me/creating-graphs-for-vpn-users/


crontab entries:

*/5 * * * * /var/www/html/openvpn/system.pl >/dev/null 2>&1

*/5 * * * * /var/www/html/openvpn/vpn.pl black >/dev/null

