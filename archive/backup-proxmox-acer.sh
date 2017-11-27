#!/bin/bash
# backupscript: v2
echo "TODO: Server no longer exists - we should backup pve-eriador instead"
exit 0

HOST="proxmox-acer.mrwire.co.uk"
DATE="`date +%Y-%m-%d`"
ssh root@$HOST bash -c "'
cd /tmp
/opt/backup-proxmox.sh
'"
scp root@$HOST:/tmp/"$HOST"_"$DATE"*.gz /media/datastore/backup/devices/device_config/
ssh root@$HOST bash -c "'
rm /tmp/*.tar.gz
'"

