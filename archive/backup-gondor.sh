#!/bin/bash
# backupscript: v3

HOST="gondor.mrwire.co.uk"
DATE="`date +%Y-%m-%d`"
DEST=/mnt/backup/devices/device_config

ssh root@$HOST bash -c "'
cd /tmp
#tar -cpzf "$HOST"_"$DATE"-fhem-config.tar.gz /opt/fhem/config
#bash /etc/init.d/weewx stop
#`pgrep -f /usr/bin/weewxd` > /dev/null
#if [[ $? -eq 0 ]]; then
#  echo "weewx still running! Not backing up DB!"
#else
#  sqlite3 /mnt/rwdata/weewx/db/weewx.sdb .dump | gzip > "$HOST"_"$DATE"-weewx.sdb.dump.gz
#  tar -cpzf "$HOST"_"$DATE"-weewx.tar.gz /mnt/rwdata/weewx/db/weewx.sdb
#fi

#tar -cpzf "$HOST"_"$DATE"-nodered.tar.gz /root/.node-red
tar -cpzf "$HOST"_"$DATE"-etc.tar.gz /etc
'"
scp root@$HOST:/tmp/"$HOST"_"$DATE"*.gz $DEST
ssh root@$HOST bash -c "'
rm /tmp/*.tar.gz
#bash /etc/init.d/weewx start
'"

