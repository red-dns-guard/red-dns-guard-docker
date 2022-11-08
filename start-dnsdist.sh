#!/bin/bash
mylogger()  { while read a;do echo $(date +%Y-%m-%d_%H:%M:%S.%3N -u)" | $1: $a" ;done ; } ;
test -f /userconfig || mkdir /userconfig
test -f /userconfig/Corefile && { cat /userconfig/Corefile > /etc/coredns/Corefile ; } ;
# Check our environment out for a syslog server
[[ -z "${REDIS_HOST}" ]] && REDIS_HOST=redis
[[ -z "${REDIS_HOST}" ]] || (echo redis-servers=$REDIS_HOST > /etc/powerdns/lua-options.conf)
(echo "#!/bin/bash"
echo 'cd /etc/powerdns/;dnsdist -C /etc/powerdns/dnsdist.conf -c' )|tee  /usr/bin/console.dns /usr/bin/dnsdist.console /usr/bin/dnsconsole
chmod +x /usr/bin/console.dns /usr/bin/dnsdist.console /usr/bin/dnsconsole & 

mkdir -p /var/spool/rsyslog
if [ ! -z ${SYSLOG_HOST} ]; then
echo "*.* @$SYSLOG_HOST:514" >  /etc/rsyslog.conf 

#    cat >> /etc/rsyslog.conf << EOF
#    *.* @$SYSLOG_HOST:514
#EOF

fi

[[ -z "$DNSDISTKEY" ]] && export DNSDISTKEY=$(for rounds in $(seq 1 24);do cat /dev/urandom |tr -cd '[:alnum:]_\-.'  |head -c48;echo ;done|grep -e "_" -e "\-" -e "\."|grep ^[a-zA-Z0-9]|grep [a-zA-Z0-9]$|tail -n1)

[[ -z "$DNSDISTKEY" ]] || (sed 's/^setKey.\+//g' -i /etc/powerdns/dnsdist.conf ; echo 'setKey("'"$DNSDISTKEY"'")' >> /etc/powerdns/dnsdist.conf )
( 
test -e /etc/coredns/hosts/alternates/fakenews-gambling/ || mkdir -p /etc/coredns/hosts/alternates/fakenews-gambling/
test -e /etc/coredns/hosts/alternates/fakenews-gambling && test -e /etc/coredns/hosts/alternates/fakenews-gambling/hosts && find /etc/coredns/hosts/alternates/fakenews-gambling -name hosts -mtime +2 && (echo "found old coredns blocklist ";ls -1lh /etc/coredns/hosts/alternates/fakenews-gambling/hosts && rm /etc/coredns/hosts/alternates/fakenews-gambling/hosts)
test -e /etc/coredns/hosts/alternates/fakenews-gambling/hosts || wget -c "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts" -O /etc/coredns/hosts/alternates/fakenews-gambling/hosts &>/tmp/log.init.coredns.adblock

test -e /etc/coredns/hosts/alternates/fakenews-gambling/hosts || { echo > /etc/coredns/hosts/alternates/fakenews-gambling/hosts ; } ;
test -e /etc/coredns ||mkdir /etc/coredns
test -e /etc/coredns/Corefile || ( echo "FAIL::NO COREDNS FILE ..trying from default";cp /Corefile.default /etc/coredns/Corefile )

test -e /etc/coredns/Corefile  && /usr/bin/coredns -dns.port 55555 -conf /etc/coredns/Corefile ) &

rsyslogd &
 





waittime=1;
server_ready=no;
waittime=1;while [[ "$server_ready" == "no" ]] ;do 
 ping $REDIS_HOST -c 2 -w 1  2>&1 |grep " packets received"|grep  " 0 packets received " || ( echo "PING"|socat stdio TCP:$REDIS_HOST:6379 |grep PONG )&& server_ready=yes;echo waiting "$waittime";sleep $waittime;waittime=$(($waittime*2));done|mylogger INIT



( which tor && tor 2>&1|mylogger TOR;sleep 2) &


(
             test -e /WHITE-dnsdist.sh && bash /WHITE-dnsdist.sh 

sleep 90 ;   bash /blocklistgen $REDIS_HOST 2>&1 |mylogger BLK

while(true);do

 sleep 86400;test -e /WHITE-dnsdist.sh && bash /WHITE-dnsdist.sh
             test -e /WHITE-dnsdist.sh && bash /WHITE-dnsdist.sh 

done

) & 

cd /etc/powerdns ;
  ( sleep 10; while(true);do echo 'showRules()';echo 'showServers()';sleep 600;done)|while(true);do dnsdist  -k "$DNSDISTKEY"  -C /etc/powerdns/dnsdist.lua 2>&1;sleep 0.2 ;done| mylogger DNS







