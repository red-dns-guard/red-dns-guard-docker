cat ~/DNSBLACK.tmp |grep -v -e ^$ -e ^#|sort -u|sed 's/.\+/SET \0. "blocked:manual"/g'|redis-cli &

cat ~/DNSWHITE.tmp | while read domain ;do 
 echo  "addAction({'"$domain"'}, PoolAction("'"bypass"'"))"
done  |docker exec -i dns-robin dnsdist -c &
cat ~/DNSWHITE.tmp | while read domain ;do 
 echo 'DEL "'${domain}'"'
done |redis-cli --pipe &
wait

