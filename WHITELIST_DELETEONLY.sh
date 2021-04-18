
cat ~/DNSWHITE.tmp | while read domain ;do 
 echo 'DEL "'${domain}'"'
done |redis-cli --pipe &
wait

