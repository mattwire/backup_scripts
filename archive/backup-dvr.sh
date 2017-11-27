#!/bin/bash
# backupscript: v2
echo "Server no longer exists"
exit 0

HOST="dvr.mrwire.co.uk"
DATE="`date +%Y-%m-%d`"
ssh root@$HOST bash -c "'
cd /tmp
tar -cpzf "$HOST"_"$DATE"-xeoma.tar.gz /usr/local/Xeoma
tar -cpzf "$HOST"_"$DATE"-etc.tar.gz /etc
'"
scp root@$HOST:/tmp/"$HOST"_"$DATE"*.gz /media/datastore/backup/devices/device_config/
ssh root@$HOST bash -c "'
rm /tmp/*.tar.gz
'"

