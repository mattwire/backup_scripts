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

function clean_staging() {
  # Clean (delete everything in) staging dir
  if [ ! -d "$STAGING_DIR" ]; then
    mkdir -p "$STAGING_DIR"
  elif [ ! -z "$STAGING_DIR" ] && [ -d "$STAGING_DIR" ] && [ ! "$STAGING_DIR" == "/" ]; then
    `rm -rf "$STAGING_DIR"/*`
  fi
}

# Get/Check Args
if [ $# -lt 1 ]; then
  echo -e ""
  echo -e "Error: You must specify whether to clean staging dir as ARG1 with 0 or 1."
  echo -e ""
  exit 1;
fi;

STAGING_CLEAN=$1

if [ "$STAGING_CLEAN" -ne 1 ]; then
  exit 0
fi

clean_staging
