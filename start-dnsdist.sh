#!/bin/bash



test -f /userconfig || mkdir /userconfig
test -f /userconfig/Corefile && { cat /userconfig/Corefile > /etc/coredns/Corefile ; } ;
# Check our environment out for a syslog server
[[ -z "${REDIS_HOST}" ]] && REDIS_HOST=redis

mkdir -p /var/spool/rsyslog
if [ ! -z ${SYSLOG_HOST+x} ]; then
    cat >> /etc/rsyslog.conf << EOF
    *.* @$SYSLOG_HOST:514
EOF

fi

[[ -z "$DNSDISTKEY" ]] && DNSDISTKEY=$(for rounds in $(seq 1 24);do cat /dev/urandom |tr -cd '[:alnum:]_\-.'  |head -c48;echo ;done|grep -e "_" -e "\-" -e "\."|grep ^[a-zA-Z0-9]|grep [a-zA-Z0-9]$|tail -n1)
cat /etc/rsyslog.conf
mkdir -p /etc/coredns/hosts/alternates/fakenews-gambling/
wget -c "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts" -O /etc/coredns/hosts/alternates/fakenews-gambling/hosts
test -f /etc/coredns/hosts/alternates/fakenews-gambling/hosts || { echo > /etc/coredns/hosts/alternates/fakenews-gambling/hosts ; } ;

/usr/bin/coredns -dns.port 55555 -conf /etc/coredns/Corefile &
rsyslogd &
which tor && /etc/init.d/tor start

( sleep 10; bash /blocklistgen
sleep 130 ;bash /WHITE-dnsdist.sh ) &



cd /etc/powerdns ;
while(true);do
  ( sleep 10; while(true);do echo 'showRules()';echo 'showServers()';sleep 360 ;done)|dnsdist  -k "$DNSDISTKEY"  -C /etc/powerdns/dnsdist.lua;
  sleep 0.2;
done

