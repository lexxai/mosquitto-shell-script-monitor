#!/bin/sh

TOKEN="YYYYYY:XXXXX"
CHAT_ID='-100ZZZZZZZZZZ'
URL="https://api.telegram.org/bot$TOKEN/deleteMessage"
LOGFILE=/mnt/dav/telegram/telegram_msgid.log
cdate=$(date '+%Y-%m-%d %H:%M:%S')
LEAVED=5
if [ -n "$1" ];then
 LEAVED=$1
fi
echo LEAVED FILES: ${LEAVED}
MID=$(head -n -${LEAVED} ${LOGFILE})
#echo "MID ${MID}"
for id in ${MID}
do
 #echo "ID ${id}"
 r=$(curl ${URL} -s \
   --form-string chat_id=${CHAT_ID} \
   --form-string message_id="${id}" )
 if [ "$r" == '{"ok":true,"result":true}' ];then
  #echo "deleted MSG $id OK"
  grep -v $id ${LOGFILE} > ${LOGFILE}.tmp
  mv -f ${LOGFILE}.tmp ${LOGFILE}
 fi
done
