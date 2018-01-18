#!/bin/bash

function check() {
  CMD=$1
  which $CMD
  if [ "$?" -gt 0 ]; then
    echo ""
    echo "Error: Command $CMD not found."
    echo ""
    exit 1
  fi
}

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

if [ ! -d $STAGING_DIR ]; then
  echo ""
  echo "Error: Staging dir ($STAGING_DIR) is missing"
  exit 1
fi

check tar
check mysqldump
if [ ! -f /opt/s3cmd/s3cmd ]; then
  echo ""
  echo "Error: You need to do git clone https://github.com/s3tools/s3cmd.git in /opt"
  echo ""
fi

# apt-get install python-dateutil

# Do the following setup
# Create the new database user, "backup".
# "{PASSWORD}" should be replaced w/ something secure!
#CREATE USER 'backup'@'localhost'
#IDENTIFIED BY ‘{PASSWORD}’; # Set a secure password

# Grant "backup" read-only privileges on all databases.
#GRANT SELECT, SHOW VIEW, RELOAD,
#REPLICATION CLIENT, EVENT, TRIGGER, LOCK TABLES
#ON *.* TO 'backup'@'localhost';
