package.path = package.path .. ";/etc/powerdns/?.lua" 
pcall(require, "luarocks.require")
redis = require 'redis'
require "tester"
require "syslog"
require "redisconn"
require "pdnsfunctions"

local controlIP = "127.0.0.1" 
local returnLOCALHOST = false
local returnCNAME = false
---local returnLOCALHOST = true
---local returnCNAME = true
local logQUERIES = false
local logBLOCKED = true
local logNXDOMAIN = false

function quote(str)
    return '"'..str..'"'
end

function nxdomain( dq )
---        return pdns.PASS, {}
---        dq.addAnswer(pdns.CNAME, "NXDOMAIN.local")
    if(client:get('count_nx') == nil)
    then
        client:set('count_nx',0)
    else
        client:incrby('count_nx', 1)
    end
    if ( logNXDOMAIN == true)
    then
         count_total=client:get('count_total')
         count_total_blocked=client:get('blocked_total')
         count_total_nxdomain=client:get('count_nx')
         sendsyslog(1004, {thedomain=dq.name,qname=tostring(dq.qname),count_percent_nx=string.format("%.2f", count_total_nxdomain/count_total*100),count_percent_blocked=string.format("%.2f", count_total_blocked/count_total*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=tostring(dq.remoteaddr),finding=blacklist_domain,querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
         ---sendsyslog(1004, {requestingip=tostring(dq.remoteaddr),thedomain=dq.qname,qname=tostring(dq.qname),querytype=translateQtype(dq.qtype)})
    end
    return true
       
end

---function postresolve( dq )
---        ---sendsyslog(3500, {thedomain=dq.name,requestingip=tostring(dq.remoteaddr),querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
---end

function preresolve( dq )
    if(client:get('count_total') == nil)
    then
        client:set('count_total',0)
    else
        client:incrby('count_total', 1)
----        local totalqueries = client:pipeline(function(p)
----            p:incrby('count_total', 1)
----            p:get('count_total')
----    
----        end)
    end
    ---sendsyslog(1001, {thedomain=dq.name,qname=tostring(dq.qname),count_total=client:get('count_total'),count_total_blocked=client:get('blocked_total'),requestingip=tostring(dq.remoteaddr),querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})

--- build the request to redis
    ---local req = buildsinkreq( dq.localaddr, dq.qname, dq.qtype )
    --- REFLECTION START
    if tostring(dq.qname) == "."
    then
       if ( logQUERIES == true)
       then
        if(client:get('blocked_total') == nil)
            then
                client:set('blocked_total',0)
        end
        sendsyslog(3501, {thedomain=dq.name,qname=tostring(dq.qname),count_percent_blocked=string.format("%.2f", client:get('blocked_total')/client:get('count_total')*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=tostring(dq.remoteaddr),finding=blacklist_domain,querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})

          ---sendsyslog(3501, {thedomain=domain,requestingip=tostring(requestorip),querytype=translateQtype(qtype),localaddr=tostring(getlocaladdress())})
          --- return pdns.DROP, {}
          return true;
         end
    else
    --- REFLECTION END
        if dq.qname ~= ''
        then
            -- check if the domain and its parents are on the redis blacklist
            local blacklist_domain = nil
            for k,target in pairs(domainswithparent(dq.qname))
            do
                if (blacklist_domain == nil)
                then
                    ---sendsyslog(2000, {thedomain=dq.name,qname=tostring(target),count_percent_blocked=string.format("%.2f", client:get('blocked_total')/client:get('count_total')*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=tostring(dq.remoteaddr),finding=blacklist_domain,querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
                    local req = target..'.'
                    blacklist_domain = client:get(req)
                    ---sendsyslog(1000, {thedomain=dq.name,requestingip=tostring(req),querytype=blacklist_domain})
                end
            end
            
            ---local blacklist_domain = client:get(req)
            if blacklist_domain ~= nil
            then
                if(client:get('blocked_total') == nil)
                then
                    client:set('blocked_total',0)
                else
                    client:incrby('blocked_total', 1)
                end
                ----local totalblocked = client:pipeline(function(p)
                ----    p:incrby('blocked_total', 1)
                ----    p:get('blocked_total')
                ----end)
                
                if ( logBLOCKED == true)
                then
                    count_total=client:get('count_total')
                    count_total_blocked=client:get('blocked_total')
                    sendsyslog(2000, {thedomain=dq.name,qname=tostring(dq.qname),count_percent_blocked=string.format("%.2f", count_total_blocked/count_total*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=tostring(dq.remoteaddr),finding=blacklist_domain,querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
                end
                ---if (tostring(dq.qname) == "logqueries.debug.dns.lan")
                ---then
                ---    client:set('loqQUERIES.settings',true)
                ---end
                ---if (tostring(dq.qname) == "lognxdomain.debug.dns.lan")
                ---then
                ---    client:set('loqNXDOMAIN.settings',true)
                ---end
                ---if (tostring(dq.qname) == "logqueries.debug.dns.lan")
                ---then
                ---    client:set('loqQUERIES.settings',true)
                ---end
	    
                -- return record type with the IP of sinkhole
                --- return 0, { {qtype=qtype, content=blacklist_domain} }
                if(returnLOCALHOST == true) then
                    if(dq.qtype == pdns.AAAA) then
                        dq:addAnswer(dq.qtype,"::1")
                    elseif(dq.qtype == pdns.A) then
                        dq:addAnswer(dq.qtype,"127.0.0.1")
                    end
                elseif(returnCNAME == true) then
                    dq:addAnswer(pdns.CNAME, tostring(blacklist_domain) )
                end
                dq:addAnswer(pdns.TXT, quote(tostring(blacklist_domain)) )
                --- dq.addAnswer(pdns.NXDOMAIN,'',120,dq.qname)
	    
                return true
	    
            end
        end
	end
    if ( logQUERIES == true)
    then
        count_total=client:get('count_total')
        count_total_blocked=client:get('blocked_total')
        sendsyslog(1001, {thedomain=dq.name,qname=tostring(dq.qname),count_percent_blocked=string.format("%.2f", count_total_blocked/count_total*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=tostring(dq.remoteaddr),querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
    end

    ---return true
    return false
end

-- parse options file to make sure the correct data is loaded
local options = get_options()
-- pass in the syslog-servers array to connect to potential syslog servers
-- pass in the redis-servers array to connect to potential redis servers
getredis(options["redis-servers"])
