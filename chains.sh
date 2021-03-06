#!/bin/sh
apt update;apt -y install proxychains;
sed -i 's/DNS_SERVER=${PROXYRESOLV_DNS:-4.2.2.2}/DNS_SERVER=${PROXYRESOLV_DNS:-1.1.1.1}/' /usr/lib/proxychains3/proxyresolv
rm /etc/proxychains.conf
echo 'strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5 127.0.0.1 9999
' > /etc/proxychains.conf
exit 0
