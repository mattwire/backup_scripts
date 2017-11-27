#!/bin/bash
# This script backs up contents of STAGING_DIR to amazon s3 in a directory with todays date (eg. 2017-01-01)

# Setup
CONF_DIR="/etc/backup"
CONF="$CONF_DIR/backup.cfg"

if [ ! -f "$CONF" ]; then
  echo "No config found in $CONF. Exiting"
  exit 1
fi

. "$CONF"

if [ ! $BACKUP_S3 ]; then
  exit 0
fi

S3="/opt/s3cmd/s3cmd"
S3_EXTRA_ARGS="--storage-class=STANDARD_IA --ssl --quiet"
S3_ACCESS="--access_key=$AWS_ACCESS_KEY --secret_key=$AWS_SECRET_KEY"
DATE="`date +%Y-%m-%d`"
S3CMD="$S3 $S3_EXTRA_ARGS $S3_ACCESS put $STAGING_DIR/* $AWS_TARGET/$DATE/"

$S3CMD
