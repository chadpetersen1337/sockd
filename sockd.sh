#!/bin/sh
yum -y groupinstall "Development Tools"
MYIP=$(wget -qO- ifconfig.me);
ifaceName=$(ip addr show | awk '/inet.*brd/{print $NF}')
MYIP2="s/xxxxxxxxx/$MYIP/g";
wget http://www.inet.no/dante/files/dante-1.4.2.tar.gz
tar -xvf dante-1.4.2.tar.gz
cd dante-1.4.2
./configure
make && make install

cat > /etc/sockd.conf <<END
user.privileged: root
user.notprivileged: nobody

internal: $ifaceName port = 1080
external: xxxxxxxxx
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
END
sed -i $MYIP2 /etc/sockd.conf;

cat > /usr/lib/systemd/system/sockd.service <<END
[Unit]
Description=Sockd Service
[Service]
Type=normal
ExecStart=/usr/local/sbin/sockd
[Install]
WantedBy=multi-user.target
END

systemctl start sockd

systemctl enable sockd

service sockd restart

useradd mikrotik999 -r
echo "mikrotik999:Elibawnos" | chpasswd
netstat -ntlp

tail -f /var/log/sockd.log
