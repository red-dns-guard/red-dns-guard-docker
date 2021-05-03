local unpack = table.unpack or unpack
function tablesplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end
function domainswithparent(domain)
    alldom={}
    fulldomain=tablesplit(tostring(domain),'.')
    if ( fulldomain ~= nil ) then
        for i = #fulldomain-1,1,-1 
        do 
           ---print(i)
           ---print(fulldomain[i])
           target=''
           if ( i ~= nil ) then
           
           for key, value in pairs({unpack( fulldomain, i)}) do
               ---print('loop',key, value)
               target=target..'.'..value
           end
           end
           ---print(target:sub(2))
           
           ---print(table.concat (unpacked,'.'))
            table.insert(alldom, target:sub(2))
            ---print(alldom[#alldom])
        end
        return alldom
        ---for k,target in pairs(fulldomain) do print(k,target) end
        end
    end
---domain = "afafs.asd.com.net"
---print ( domainswithparent(domain) )
---for k,target in pairs(domainswithparent(domain)) do print('searching',target) end
