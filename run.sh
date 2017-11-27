#!/bin/bash

# Setup
CONF_DIR="/etc/backup"
CONF="$CONF_DIR/backup.cfg"

if [ ! -f "$CONF" ]; then
  echo "No config found in $CONF. Exiting"
  exit 1
fi

. "$CONF"

# Cleanup before we start
if [ ! -d "$STAGING_DIR" ]; then
  mkdir -p "$STAGING_DIR"
elif [ ! -z "$STAGING_DIR" ] && [ -d "$STAGING_DIR" ] && [ ! "$STAGING_DIR" == "/" ]; then
  `rm -rf "$STAGING_DIR"/*`
fi
# Backup files/dirs
$SCRIPTS_DIR/backup_tar.sh `hostname` tar.include tar.exclude
# Backup all mysql databases
$SCRIPTS_DIR/backup_mysql.sh
# Save to S3
$SCRIPTS_DIR/dest_s3.sh

# Rotate backups (for this hosts bucket)
$SCRIPTS_DIR/rotate_s3.sh $AWS_TARGETS
