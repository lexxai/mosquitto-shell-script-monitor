#!/bin/sh

function notify()
{
  #echo "to telegram $1"
  /root/telegram/totelegram.sh $1 $2 &
}

function publish()
{
 mosquitto_pub -t "$1" -m "$2"
}


#Wait ready of dav file system
sleep 30
for i in 0 1 2 3 4 5 6 7 8 9 10; do
 if [ ! -d "/mnt/dav/video" ];then
  sleep 60
 else
  break
 fi
done 

#icons emoji list in bytes from unicode https://www.unicode.org/emoji/charts/full-emoji-list.html by https://onlineunicodetools.com/convert-unicode-to-bytes
iON=$'\xf0\x9f\x9f\xa9'
iOFF=$'\xF0\x9F\x94\xB4'
iDoor=$'\xF0\x9F\x9A\xAA'
iLockON=$'\xf0\x9f\x94\x90'
iLockOFF=$'\xF0\x9F\x94\x93'
iBellON=$'\xF0\x9F\x94\x94'
iBellOFF=$'\xF0\x9F\x94\x95'
iOnline=$'\xf0\x9f\x99\x82'
iOffline=$'\xf0\x9f\x91\xbf'
iLED=$'\xf0\x9f\x94\x86'
iPIR=$'\xf0\x9f\x8f\x83'
iWarn=$'\xE2\x9A\xA0'
iWiFi1=$'\xF0\x9F\x93\xB6'
iWiFi0=$'\xF0\x9F\x93\xB4'
iUser01=$'\xF0\x9F\x91\xB6'
iUser02=$'\xF0\x9F\x91\xA9'
iHOME=$'\xF0\x9F\x91\xA8\xE2\x80\x8D\xF0\x9F\x91\xA9\xE2\x80\x8D\xF0\x9F\x91\xA7\xE2\x80\x8D\xF0\x9F\x91\xA7'

#stored states
#object Armed
stateArmed=OFF
#state lock of door
stateLocked=OFF
#state that is moving inside before door opened
stateAtHome=0

#MAIN LOOP by listen subscribed mosquitto_sub fixed topics list
while true; do
 mosquitto_sub -v -t 'door/#' -t 'stat/pir_01/RESULT' -t '+/+/LWT'  -q 0  | \
  while read msg; do
    #parse topic and values on every new line of mqtt events 
    t=$(echo $msg|awk '{print $1}')
    v=$(echo $msg|awk '{print $2}')
    #echo "readed:  $msg. $t:$v"
    #action for selected topics
    case "$t" in
     "door/closed")
      #eval used for select icon based on variables
      a=$(eval "echo \${i${v}}")
      #reset state until new motion 
      stateAtHome=0
      #notify message to telegram bot
      notify "${iDoor}${a}" 0
     ;;
     "door/locked")
      a=$(eval "echo \${i${v}}")     
      b=$(eval "echo \${iLock${v}}")
      notify "${b}${a}" 0
      stateLocked=$v
      if [ "$stateLocked" == "ON" ] && [ "$stateArmed" == "ON" ] ;then
          #additional action on Tasmota device by publish mqtt command, (need off lights)
          publish "cmnd/led_01/var1" "2"
      fi
     ;;
     "door/armed")
       a=$(eval "echo \${iBell${v}}")
       if [ "$stateAtHome" -eq 1 ];then
        #if was moving need add next icon that show "peoples inside" wnen object was armed
        a="${a}${iHOME}"
       fi
       notify "$a" 0
       stateArmed=$v
       if [ "$stateLocked" == "ON" ] && [ "$stateArmed" == "ON" ] ;then
          publish "cmnd/led_01/var1" "2"
       fi
     ;;
     "door/alarm")
       case "$v" in
        "close")
           a="${iWarn}${iDoor}${iOFF}"
           notify "$a" 0
        ;;
        "lock")
           a="${iWarn}${iLockOFF}${iOFF}"
           notify "$a" 0
        ;;
       esac
     ;;
     "stat/pir_01/RESULT")
      if [ "$stateLocked" == "ON" ] && [ "$v" == '{"PIR":{"Action":"ON"}}' ];then
       #moving is, set state
       stateAtHome=1
      fi
     ;;
     "tele/led_01/LWT")
       #device LIVE state was changed
       a=$(eval "echo \${i${v}}")     
       notify "${iLED}$a" 0
       publish "cmnd/pir_01/event" "lwtled=$v"
     ;;
     "tele/pir_01/LWT")
       a=$(eval "echo \${i${v}}")     
       notify "${iPIR}$a" 0
     ;;
     "tele/wifi_user01/LWT")
       #status of Wifi user client was changed
       a=$(eval "echo \${iWiFi${v}}")     
       notify "${iUser01}$a" 0
     ;;
     "tele/wifi_user02/LWT")
       a=$(eval "echo \${iWiFi${v}}")     
       notify "${iUser02}$a" 0
     ;;
     esac
  done
  sleep 5
  echo "restat loop"
done  
  
