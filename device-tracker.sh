#!/bin/sh

uUser01='XX:XX:XX:XX:XX:XX'
uUser02='XX:XX:XX:XX:XX:XX'
users="User01 User02"

next=

function publish()
{
 mosquitto_pub -t "$1" -m "$2" -r
}


#MAIN
sleep 120

for m in $users; do
  eval p${m}=0
done 

while true; do
 for m in $users; do
  um=$(eval "echo \${u${m}}")
  us=$( iwinfo wlan0 assoclist | grep -m 1 -c $um )
  ps=$(eval "echo \${p${m}}")
  if [ "$us" -ne $ps ];then
   eval p${m}=$us
   if [ -n "$next" ];then
     #echo "N m:$m us:$us ps:$ps" 
     publish "tele/wifi_$m/LWT" "$us"
   fi
  fi
 #echo "m:$m us:$us ps:$ps"  
 done 
 next=1 
 #echo sleep
 sleep 90
done

