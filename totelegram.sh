#!/bin/sh

MESSAGE="$1"
if [ -z "${MESSAGE}" ];then
 echo "message is empty"
 exit
fi
TOKEN="YYYYYY:XXXXX"
CHAT_ID='-100ZZZZZZZZZZ'
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
LOG="/mnt/dav/telegram/telegram_msgid.log"
cdate=$(date '+%Y-%m-%d %H:%M:%S')
host="WRT"
if [ "$2" == "0" ];then
 MESSAGE1="${MESSAGE}"
else
 MESSAGE1="${cdate} [${host}]:${MESSAGE}$2"
fi
B=$(curl -s -X POST $URL \
 -d chat_id=$CHAT_ID -d text="${MESSAGE1}"|jq .result.message_id)
if [ ! -z "$B" ];then
 echo $B >> $LOG
fi
