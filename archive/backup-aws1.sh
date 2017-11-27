#!/bin/bash
# backupscript: v4

HOST="aws1.mjwconsult.co.uk"
USER=admin
DATE="`date +%Y-%m-%d`"
DEST=/mnt/backup/devices/device_config

ssh $USER@$HOST bash -c "'
cd /tmp
tar -cpzhf "$HOST"_"$DATE"-redmine.tar.gz /opt/redmine
mysqldump -u redmine redmine --password=N1xHyxeDNc0pLqXprt4n | gzip > "$HOST"_"$DATE"-redmine-mysql.dump.gz
'"
scp $USER@$HOST:/tmp/"$HOST"_"$DATE"*.gz $DEST
ssh $USER@$HOST bash -c "'
rm /tmp/"$HOST"_"$DATE"*.gz
'"

