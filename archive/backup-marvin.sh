#!/bin/bash
#backupscript: v1
HOST="marvin.mrwire.co.uk"
DATE="`date +%Y-%m-%d`"
DEST=/mnt/backup/devices/device_config

ssh root@$HOST bash -c "'
cd /tmp
tar -cpzf "$HOST"_"$DATE"-fhem-config.tar.gz /opt/fhem/config
tar -cpzf "$HOST"_"$DATE"-nodered.tar.gz /root/.node-red
tar -cpzf "$HOST"_"$DATE"-etc.tar.gz /etc
'"
scp root@$HOST:/tmp/"$HOST"_"$DATE"*.tar.gz $DEST
ssh root@$HOST bash -c "'
rm /tmp/*.tar.gz
'"

