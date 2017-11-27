#!/bin/bash
# backupscript:
echo "TODO: Backup UPS stuff?"

HOST="emonpi-understairs.mrwire.co.uk"
DATE="`date +%Y-%m-%d`"
DEST=/mnt/backup/devices/device_config
ssh root@$HOST bash -c "'
cd /tmp
tar -cpzf "$HOST"_"$DATE"-nodered.tar.gz /root/.node-red
tar -cpzf "$HOST"_"$DATE"-etc.tar.gz /etc
tar -cpzf "$HOST"_"$DATE"-emonhub.tar.gz /home/pi
'"
scp root@$HOST:/tmp/"$HOST"_"$DATE"*.gz $DEST
ssh root@$HOST bash -c "'
rm /tmp/*.tar.gz
'"

