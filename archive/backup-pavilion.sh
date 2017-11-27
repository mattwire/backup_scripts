#!/bin/bash
# backupscript: v4

HOST="pavilion.mrwire.co.uk"
DATE="`date +%Y-%m-%d`"
DEST=/mnt/backup/system/pavilion

sfpath=/root/backup
root=/dev/sda1
ssh root@$HOST bash -c "'
cd /tmp
apt-get clean
echo "Root drive: ${root}"
mkdir -p ${sfpath}
dd if=${root} of=${sfpath}/grub.dd bs=446 count=1
dd if=${root} of=${sfpath}/grub_parts.dd bs=512 count=1
/sbin/blkid > ${sfpath}/uuids
dpkg -l > ${sfpath}/packages
#tar -cpzf --one-file-system - / | ssh mjw-backup@omv \"cat - > /media/datastore/backup/system/\"$HOST\"_\"$DATE\"-rootdisk.tar.gz\"
'"
mkdir -p ${DEST}
rsync -aAXv root@$HOST:/* ${DEST} \
        --delete \
        --exclude=/dev \
        --exclude=/proc \
        --exclude=/sys \
        --exclude=/tmp \
        --exclude=/run \
        --exclude=/mnt \
        --exclude=/media \
        --exclude=/lost+found \
        --exclude=/export \
        --exclude=/home/ftp \
        --exclude=/srv/ftp \
        --exclude=/srv/tftp
