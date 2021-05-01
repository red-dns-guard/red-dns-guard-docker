#!/bin/bash
# Check our environment out for a syslog server
[[ -z "${REDIS_HOST}" ]] && REDIS_HOST=redis

if [ ! -z ${SYSLOG_HOST+x} ]; then
    cat >> /etc/rsyslog.conf << EOF
    *.* @$SYSLOG_HOST:514
EOF
fi
cat /etc/rsyslog.conf
/usr/bin/coredns &
rsyslogd 

cd /etc/powerdns ;while(true);do  ( sleep 10; while(true);do echo 'showRules()';echo 'showServers()';sleep 360 ;done)|dnsdist --local=0.0.0.0:53   -k "$DNSDISTKEY"  -C /etc/powerdns/dnsdist.conf;sleep 0.2;done &
bash /blocklistgen
sleep 3 ;bash /WHITE-dnsdist.sh

