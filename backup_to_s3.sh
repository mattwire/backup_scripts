#!/bin/bash
if [ ! -f "/etc/backup.cfg" ]; then
  echo "No config found in /etc/backup.cfg. Exiting"
  exit 1
fi

. /etc/backup.cfg

if (( ! $BACKUP_S3 )); then
  exit 0
fi

# Use PASSPHRASE if you want encryption
export PASSPHRASE=$AWS_PASSPHRASE
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
HOSTNAME=`hostname`

# https://raim.codingfarm.de/blog/2015/03/12/backup-with-duply-to-amazon-s3-backendexception-no-connection-to-backend/
export S3_USE_SIGV4="True"

nice -10 /usr/bin/duplicity remove-older-than 1Y $AWS_TARGET
nice -10 /usr/bin/duplicity --s3-use-rrs --include="/var/www" --include="/root/staging" --include="/root/backup_scripts" --exclude="**" / $AWS_TARGET --full-if-older-than 1M | mail -s "$HOSTNAME: Nightly Backup Results" $EMAIL
