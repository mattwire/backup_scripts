#!/bin/bash
# This script backs up contents of STAGING_DIR to amazon s3 in a directory with todays date (eg. 2017-01-01)

# Setup
CONF_DIR="${HOME}/.mjwbackup"
CONF="$CONF_DIR/backup.cfg"

if [ ! -f "$CONF" ]; then
  CONF_DIR="/etc/backup"
  CONF="$CONF_DIR/backup.cfg"
  if [ ! -f "$CONF" ]; then
    echo "No config found in $CONF. Exiting"
    exit 1
  fi
fi

. "$CONF"

if [ "$BACKUP_S3" -ne 1 ]; then
  exit 0
fi

S3_STORAGE="--storage-class=STANDARD_IA"
S3_PUT_ARGS="--ssl --quiet"
S3_SYNC_ARGS="--ssl --recursive --skip-existing --no-delete-removed -v"
S3_ACCESS="--access_key=$AWS_ACCESS_KEY --secret_key=$AWS_SECRET_KEY"
DATE="`date +%Y-%m-%d`"
if [ $S3_SYNC_MODE -eq 1 ]; then
  S3CMD="$PATH_S3CMD $S3_STORAGE $S3_SYNC_ARGS $S3_ACCESS sync $STAGING_DIR/ $AWS_TARGET/"
else
  S3CMD="$PATH_S3CMD $S3_STORAGE $S3_PUT_ARGS $S3_ACCESS put $STAGING_DIR/* $AWS_TARGET/$DATE/"
fi

$S3CMD
