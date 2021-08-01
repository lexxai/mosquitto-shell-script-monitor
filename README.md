# mosquitto-shell-script-monitor
Shell script for monitor mosquitto topics, and send notify messages

Sheel script loaded by start on OpenWRT device, and in infinite loop listen mqtt topics by mosquitto_pub. 
MQTT mesagess in general received from Tasmota devices and send to Tasmota devices.

Telegram messages use unicode emoji icons:

![зображення](https://user-images.githubusercontent.com/3278842/127754810-28c87610-4d7a-446d-aad5-f4920a3a6329.png)

Emoji list: https://www.unicode.org/emoji/charts/full-emoji-list.html 

tools for convert unicode to string of bytes: https://onlineunicodetools.com/convert-unicode-to-bytes


More info here:
https://lexxai.blogspot.com/2021/01/mqtt-openwrt-telegram-emoji.html


Tasmoto devices:
- https://lexxai.blogspot.com/2020/09/offdarks-modern-led-smart-ceiling-light.html


Files: 
- mqtt-jobs.sh, main loop script, stared on boot as mqtt-jobs.sh&
- totelegram.sh,
  this script send messages via api.telegram.org and curl with saving message ID to log file on dav file system.

- telegram-delete-old.sh, started daily by cron,
  this script purge old messages via api.telegram.org and curl with use message ID from log file on dav file system.
