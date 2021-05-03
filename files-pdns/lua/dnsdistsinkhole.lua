package.path = package.path .. ";/etc/powerdns/?.lua" 
pcall(require, "luarocks.require")
redis = require 'redis'
require "tester"
require "syslog"
--require "syslog-dnsdist" -- merged
require "redisconn"
require "pdnsfunctions"


local controlIP = "127.0.0.1" 
local returnLOCALHOST = false
local returnCNAME = false
---local returnLOCALHOST = true
---local returnCNAME = true
local logQUERIES =  false
local logBLOCKED =  true
local logNXDOMAIN = false

if ( pdns == nil ) then  -- gtfo with dnsdist not being able to return TXT ( no , spoofraw won't do it )
  returnCNAME     = false
  returnLOCALHOST = true
  --returnCNAME = true  -- oh , second GTFO, dnsdist refuses to return valid cnames
  -- dnsdist seems to be pure crap as the others 
end

local function isNaN( v )
   if ( v == nil ) then
   return true
---   elseif (type( v ) == "number" and v ~= v) then
   elseif (type( v ) == "number") then
        return false
   end
end

function quote(str)
    return '"'..str..'"'
end

function refusedquery(dq)
return DNSAction.Refused
end



addAction(AndRule({QNameRule('blocked.'), QTypeRule(DNSQType.MX)}),LuaAction(refusedquery) )
addAction('blocked.',SpoofAction({'127.0.0.1','::1'} , {ttl=3600} ))

--addAction(AndRule({QNameRule('blocked.'), QTypeRule(DNSQType.AAAA)}),SpoofAction("::1", {ttl=3600}) )
--addAction(AndRule({QNameRule('blocked.'), QTypeRule(DNSQType.A)}),SpoofAction("127.0.0.1", {ttl=3600}) )

---addAction(AndRule({QNameRule('host.blocked.'), QTypeRule(DNSQType.MX)}),LuaAction(refusedquery) )
---addAction(AndRule({QNameRule('host.blocked.'), QTypeRule(DNSQType.AAAA)}),SpoofAction("::1", {ttl=3600}) )
---addAction(AndRule({QNameRule('host.blocked.'), QTypeRule(DNSQType.A)}),SpoofAction("127.0.0.1", {ttl=3600}) )


----function nxdomain( dq )
-------        return pdns.PASS, {}
-------        dq.addAnswer(pdns.CNAME, "NXDOMAIN.local")
----    if(client:get('count_nx') == nil)
----    then
----        client:set('count_nx',0)
----    else
----        client:incrby('count_nx', 1)
----    end
----    if ( logNXDOMAIN == true)
----    then
----         count_total=client:get('count_total')
----         count_total_blocked=client:get('blocked_total')
----         count_total_nxdomain=client:get('count_nx')
----         sendsyslog(1004, {thedomain=dq.name,qname=tostring(dq.qname),count_percent_nx=string.format("%.2f", count_total_nxdomain/count_total*100),count_percent_blocked=string.format("%.2f", count_total_blocked/count_total*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=dq.remoteaddr:tostring(),finding=blacklist_domain,querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
----         ---sendsyslog(1004, {requestingip=dq.remoteaddr:tostring(),thedomain=dq.qname,qname=tostring(dq.qname),querytype=translateQtype(dq.qtype)})
----    end
----    return true
----       
----end


---function postresolve( dq )
---        ---sendsyslog(3500, {thedomain=dq.name,requestingip=dq.remoteaddr:tostring(),querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
---end



function preresolve( dq )
    local myqname = ""
    if ( pdns == nil ) then
		myqname=dq.qname:toString()
    else
		myqname=dq.qname:toString()
    end
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
    if(client:get('blocked_total') == nil)
    then
       client:set('blocked_total',0)
    end
     ---sendsyslog(1000,"debug.beforelog1")
  
    if ( logQUERIES == true)
    then
    count_total_blocked=client:get('blocked_total')
        if ( isNaN(count_total_blocked) == true  ) then
            client:set('bocked_total',0)
            count_total_blocked=0
        end        

        count_total=client:get('count_total')
        if ( isNaN(count_total) ) then
            client:set('count_total',0)
            count_total=0
        end
      sendsyslog(1001, {thedomain=dq.name,qname=tostring(myqname),count_percent_blocked=string.format("%.2f", count_total_blocked/count_total*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=dq.remoteaddr:tostring(),querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
    end

    ---sendsyslog(1001, {thedomain=dq.name,qname=tostring(myqname),count_total=client:get('count_total'),count_total_blocked=client:get('blocked_total'),requestingip=dq.remoteaddr:tostring(),querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})

--- build the request to redis
    ---local req = buildsinkreq( dq.localaddr, myqname, dq.qtype )
    --- REFLECTION START
    if tostring(myqname) == "."
    then
       ---if ( logQUERIES == true)
       ---then
       --- if(client:get('blocked_total') == nil)
       ---     then
       ---         client:set('blocked_total',0)
       --- end
       --- sendsyslog(3501, {thedomain=dq.name,qname=tostring(myqname),count_percent_blocked=string.format("%.2f", client:get('blocked_total')/client:get('count_total')*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=dq.remoteaddr:tostring(),finding=blacklist_domain,querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
	   ---
       ---   ---sendsyslog(3501, {thedomain=domain,requestingip=tostring(requestorip),querytype=translateQtype(qtype),localaddr=tostring(getlocaladdress())})
       ---   --- return pdns.DROP, {}
       ---   if ( pdns == nil ) then
       ---      return DNSAction.Refused, ""      -- refuse
       ---   else
       ---      return true;
       ---   end
       ---  end
    else
    
    --- REFLECTION END
        if myqname ~= ''  -- not empty
        then
            -- check if the domain and its parents are on the redis blacklist
            local blacklist_domain = nil
            for k,target in pairs(domainswithparent(myqname))
            do
                if (blacklist_domain == nil)
                then
                    ---sendsyslog(2000, {thedomain=dq.name,qname=tostring(target),count_percent_blocked=string.format("%.2f", client:get('blocked_total')/client:get('count_total')*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=dq.remoteaddr:tostring(),finding=blacklist_domain,querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
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
                    sendsyslog(2000, {thedomain=dq.name,qname=tostring(myqname),count_percent_blocked=string.format("%.2f", count_total_blocked/count_total*100),count_total=count_total,count_total_blocked=count_total_blocked,requestingip=dq.remoteaddr:tostring(),finding=blacklist_domain,querytype=translateQtype(dq.qtype),localaddr=dq.localaddr:toStringWithPort()})
                end
                ---if (tostring(myqname) == "logqueries.debug.dns.lan")
                ---then
                ---    client:set('loqQUERIES.settings',true)
                ---end
                ---if (tostring(myqname) == "lognxdomain.debug.dns.lan")
                ---then
                ---    client:set('loqNXDOMAIN.settings',true)
                ---end
                ---if (tostring(myqname) == "logqueries.debug.dns.lan")
                ---then
                ---    client:set('loqQUERIES.settings',true)
                ---end
	    
                -- return record type with the IP of sinkhole
                --- return 0, { {qtype=qtype, content=blacklist_domain} }
                if(returnLOCALHOST == true) then
                    --if(dq.qtype == pdns.AAAA) then
                    if(dq.qtype == DNSQType.AAAA) then
                        if ( pdns == nil ) then
                           return DNSAction.Spoof, "::1" -- to local v6
                        else
                            dq:addAnswer(dq.qtype,"::1")    
                        end
                        
                    elseif(dq.qtype == DNSQType.A) then
                        if ( pdns == nil ) then
                            return DNSAction.Spoof, "127.0.0.1" -- to local v6
                        else
                            dq:addAnswer(dq.qtype,"127.0.0.1")
                        end
                    else
                        return DNSAction.Refused
                    end
                elseif(returnCNAME == true) then
                        if ( pdns == nil ) then
                            return DNSAction.Spoof, "host."..tostring(blacklist_domain) , {ttl=120,aa=true} -- to CNAME
                        else
                            dq:addAnswer(pdns.CNAME, "host."..tostring(blacklist_domain) )
                        end
                else
                    if ( pdns == nil ) then
                    -- only reached  when dnsdist shall not return cname or localhost
                    -- dnsdist refuses to work like documented (spoofing raw bla , just a joke in their manual)
                    -- catched above to return cname on dnsdist (gtfo!)
                        ---return DNSAction.SpoofRaw, "asd"
                        ---SpoofRawAction({"\003aaa\004bbbb", "\003ccc"})
                        ---local answ=dq.qname:toDNSString()
                        return DNSAction.SpoofRaw, "\003aaa\004bbbb" , {ttl=120}
                    else
                        dq:addAnswer(pdns.TXT, quote(tostring(blacklist_domain)) )
                        return true
                    end
                 end
                --- dq.addAnswer(pdns.NXDOMAIN,'',120,myqname)
            end
        end
	end
    ---sendsyslog(1000,"debug.endrsolv")

    ---return true

     if ( pdns == nil ) then
        return DNSAction.None, ""
     else
        return false
       
     end
end


-- parse options file to make sure the correct data is loaded
local options = get_options()
-- pass in the syslog-servers array to connect to potential syslog servers
-- pass in the redis-servers array to connect to potential redis servers
getredis(options["redis-servers"])


---makeKey()
---setKey("sWWalOkXJH4cNVwyLaJdomJFOrkmi4l1av7R1fNsg40=")
---newServer({address="10.1.1.1:533", qps=300})
