#!/bin/bash
# backupscript: v2

HOST="garagepi.mrwire.co.uk"
DATE="`date +%Y-%m-%d`"
DEST=/mnt/backup/devices/device_config
ssh root@$HOST bash -c "'
cd /tmp
/opt/backup-weewx.sh
tar -cpzf "$HOST"_"$DATE"-nodered.tar.gz /root/.node-red
tar -cpzf "$HOST"_"$DATE"-etc.tar.gz /etc
'"
scp root@$HOST:/tmp/"$HOST"_"$DATE"*.gz $DEST
ssh root@$HOST bash -c "'
rm /tmp/*.tar.gz
'"

