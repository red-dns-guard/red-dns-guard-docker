# red-dns-guard-docker

## Config files:
* files-pdns/lua/lua-options.conf
  this one is not tracked by git , so adjust ist according to SUBNET_PREFIX=



corefile main resolver example with nextdns 

```

.:5301 {
    bind 127.0.0.1
    #bind 10.1.1.1
    forward . tls://192.145.127.148 tls://149.154.157.148  {
        tls_servername ACCOUNT.dns.nextdns.io
    health_check 45s
    }
    cache 360
}   

.:5302 {
    bind 127.0.0.1
    #bind 10.1.1.1
    forward . tls://149.154.157.148 tls://192.145.127.148  {
        tls_servername ACCOUNT.dns.nextdns.io
    health_check 45s
    
    }
    cache 360
}   
    
    
.:5303 {
    bind 127.0.0.1
    #bind 10.1.1.1
    forward . tls://149.154.157.148 tls://192.145.127.148  {
        tls_servername ACCOUNT.dns.nextdns.io
    health_check 45s
    }
    cache 360
}   

```
