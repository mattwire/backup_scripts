#!/bin/bash
# Backup all mysql databases on host (except management DBs)

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

if [ "$BACKUP_MYSQL" -ne 1 ]; then
  exit 0
fi

# Get list of dbs and dump them all
MYSQLDUMP="$(which mysqldump)"
MYSQL="$(which mysql)"
GZIP="$(which gzip)"

# get a list of databases
DBCOUNT=`echo "$MYSQL_DBLIST" | wc -w`
if [ $DBCOUNT -gt 0 ]; then
  databases=$MYSQL_DBLIST
else
  # User must be able to run SHOW_DATABASES to get list of all databases
  databases=`$MYSQL $MYSQL_ACCESS -e "SHOW DATABASES;" \
    | tr -d "| " \
    | grep -v "\(Database\|information_schema\|performance_schema\|mysql\|test\|sys\)"`
fi

DATE="`date +%Y-%m-%d_%H%M`"

for db in $databases; do
  SQLGZ_NAME=$db"_$DATE.sql.gz"
  $MYSQLDUMP $MYSQL_ACCESS --force --opt --databases "$db" | $GZIP -c > "$STAGING_DIR/$SQLGZ_NAME"
done

