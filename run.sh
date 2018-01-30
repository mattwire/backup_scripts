#!/bin/bash

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

# Staging Dir Pre
$SCRIPTS_DIR/dir_staging.sh $STAGING_CLEAN_PRE
# Backup files/dirs
$SCRIPTS_DIR/backup_tar.sh ${HOSTNAME} tar.include tar.exclude
# Backup all mysql databases
$SCRIPTS_DIR/backup_mysql.sh
# Save to S3
$SCRIPTS_DIR/dest_s3.sh
# Staging Dir Post
$SCRIPTS_DIR/dir_staging.sh $STAGING_CLEAN_POST

# Rotate backups (for this hosts bucket)
$SCRIPTS_DIR/rotate_s3.sh "${CONF_DIR}/buckets.rotate"

