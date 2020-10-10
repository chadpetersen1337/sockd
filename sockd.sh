#!/bin/sh
yum -y groupinstall "Development Tools"
MYIP=$(wget -qO- ifconfig.me);
ifaceName=$(ip addr show | awk '/inet.*brd/{print $NF}')
wget http://www.inet.no/dante/files/dante-1.4.2.tar.gz
tar -xvf dante-1.4.2.tar.gz
cd dante-1.4.2
./configure
make && make install

echo 'user.privileged: root
user.notprivileged: nobody

internal: $ifaceName port = 1080
external: $MYIP
socksmethod: username
logoutput: syslog stdout /var/log/sockd.log
client pass {
  from: 0.0.0.0/0 port 1-65535 to: 0.0.0.0/0
  clientmethod: none
  log: connect error
}
socks pass {
  from: 0.0.0.0/0 port 1-65535 to: 0.0.0.0/0
  socksmethod: username
  log: connect error
  command: bind connect udpassociate
}
' > /etc/sockd.conf

echo '[Unit]
Description=Sockd Service
[Service]
Type=normal
ExecStart=/usr/local/sbin/sockd
[Install]
WantedBy=multi-user.target
' > /usr/lib/systemd/system/sockd.service

systemctl start sockd

systemctl enable sockd

service sockd restart

useradd mikrotik999 -r
echo "mikrotik999:Elibawnos" | chpasswd
netstat -ntlp

tail -f /var/log/sockd.log
