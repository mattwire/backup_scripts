#!/bin/bash
if [ ! -f "/etc/backup.cfg" ]; then
  echo "No config found in /etc/backup.cfg. Exiting"
  exit 1
fi

. /etc/backup.cfg

if (( ! $BACKUP_CONFIG )); then
  exit 0
fi

RSYNC="$(which rsync)"

$RSYNC -a --delete "$CONFIG_SRC_DIR/" "$CONFIG_BACKUP_DIR"
