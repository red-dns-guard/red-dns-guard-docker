---dnsdist
    function sendsyslog( code, details )
    	local msg = syslogcodes[code]
    	local prepend = "pdns_recursor"
    	if not msg then
    		code = 2999
    		msg = syslogcodes[code]
    	end   
    	 if code >= 1000 and code <= 1999 then
             infolog(json.encode({app=prepend,id=msg,querydetails=details}))
    	 elseif code >= 2000 and code <= 2999 then
             warnlog(json.encode({app=prepend,id=msg,querydetails=details}))
    	 elseif code >= 3000 and code <= 3999 then
             errlog(json.encode({app=prepend,id=msg,querydetails=details}))
         end
    end


