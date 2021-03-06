FROM alpine
#FROM ubuntu:20.04
MAINTAINER profit <profit@ccmo.me>
# Grab powerdns bits
RUN apk add dnsdist-luajit || apk add dnsdist lua-redis lua-cjson coreutils tor
RUN apk add luajit lua5.1-redis  lua5.1-socket lua5.1-cjson lua-json4 bash rsyslog curl wget sed grep jq redis pv socat
RUN /bin/bash -c " uname -m|grep x86_64 && wget -O- https://github.com/coredns/coredns/releases/download/v1.6.9/coredns_1.6.9_linux_amd64.tgz|tar xvz;ls; chmod +x coredns ;mv coredns /usr/bin" || true
RUN /bin/bash -c " uname -m|grep aarch64 && wget -O- https://github.com/coredns/coredns/releases/download/v1.6.9/coredns_1.6.9_linux_arm64.tgz|tar xvz;ls; chmod +x coredns ;mv coredns /usr/bin" || true
#RUN wget -O- "https://github.com/coredns/coredns/releases/download/v1.6.9/coredns_1.6.9_linux_amd64.tgz" |tar xvz -C /usr/bin && chmod +x /usr/bin/coredns  && 

#RUN /bin/ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime && export DEBIAN_FRONTEND=noninteractive  && apt-get update &&  apt-get -y  install lua5.1 luarocks curl wget libssl-dev dnsutils gnupg2 && apt-get clean 
#RUN /bin/ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime && export DEBIAN_FRONTEND=noninteractive  && apt-get update &&   curl https://repo.powerdns.com/CBC8B383-pub.asc | apt-key add - && \
#echo "deb [arch=amd64] http://repo.powerdns.com/ubuntu focal-rec-master main" |tee /etc/apt/sources.list.d/pdns.list &&  echo ' Package: pdns-* \
#Pin: origin repo.powerdns.com \
#Pin-Priority: 600' > /etc/apt/preferences.d/pdns &&  apt-get update &&  apt-get -y  install lua5.1 luarocks curl wget pdns-recursor  liblua5.1-dev libssl-dev dnsutils && apt-get clean 

# Grab luarocks bits
#RUN luarocks install luasocket && luarocks install json4lua && luarocks install redis-lua
# Hackey mc' hackerson startup script
ADD start-dnsdist.sh /start.sh
EXPOSE 53
entrypoint /bin/bash /start.sh
RUN mkdir -p /var/run/pdns-recursor 
# Copy over config files
COPY WHITELIST.sh WHITELIST_DELETEONLY.sh blocklistgen /
COPY files-pdns/dnsdist.conf files-pdns/recursor.conf adlistindex.list /etc/powerdns/
COPY files-pdns/rsyslog.conf /etc/rsyslog.conf
COPY files-pdns/lua/* /etc/powerdns/
COPY Corefile /etc/coredns/Corefile
RUN ln -sf /etc/powerdns/dnsdist.conf /etc/powerdns/dnsdist.lua
#RUN mkdir /etc/powerdns/lua
