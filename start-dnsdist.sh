#!/bin/bash
# Check our environment out for a syslog server
: ${REDIS_HOST:=redis}

if [ ! -z ${SYSLOG_HOST+x} ]; then
    cat >> /etc/rsyslog.conf << EOF
    *.* @$SYSLOG_HOST:514
EOF
fi
cat /etc/rsyslog.conf
rsyslogd 

cd /etc/powerdns ;while(true);do (while(true);do sleep 3600;done)|dnsdist --local=0.0.0.0:53   -k "$DNSDISTKEY"  -C /etc/powerdns/dnsdist.lua;sleep 0.2;done &
bash /blocklistgen
sleep 3 ;bash /WHITE-dnsdist.sh
