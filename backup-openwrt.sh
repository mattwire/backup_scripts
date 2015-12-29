#!/bin/sh
# Backup openwrt configuration
# Generate package list /etc/package-list and backup /overlay/etc since this is what has changed.
# http://wiki.openwrt.org/doc/howto/generic.backup

if [ -z $1 ]; then
	echo "Usage: backup-openwrt <host/ip>"
	exit 0
fi

HOST=$1
WHEN=$(date +"%Y-%m-%d_%H%M")
FILE=/tmp/backup-$HOST-$WHEN.tar.gz

echo "When prompted, enter root password to generate backup on openwrt..."
#ssh root@$HOST "opkg list-installed > /etc/package-list && tar -czf $FILE /overlay/etc"
ssh root@$HOST "opkg list-installed > /etc/package-list && sysupgrade --create-backup $FILE"
echo "Now, when prompted, enter root password again to get the backup file from openwrt..."
scp root@$HOST:$FILE ./
ssh root@$HOST "rm /tmp/backup*.tar.gz"
echo "Created backup file $(basename $FILE) containing package list and /overlay/etc on $HOST."
