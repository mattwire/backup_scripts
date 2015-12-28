#!/bin/bash
if [ ! -f "/etc/backup.cfg" ]; then
  echo "No config found in /etc/backup.cfg. Exiting"
  exit 1
fi

. /etc/backup.cfg

if (( ! $BACKUP_MYSQL )); then
  exit 0
fi

MYSQLDUMP="$(which mysqldump)"
MYSQL="$(which mysql)"
GZIP="$(which gzip)"
SKIPDB="information_schema performance_schema"

if [ ! -d $MYSQL_BACKUP_DIR ]; then
  echo "Backup destination does not exist. Creating $MYSQL_BACKUP_DIR"
  mkdir -p $MYSQL_BACKUP_DIR
fi

rm "$MYSQL_BACKUP_DIR/*sql" > /dev/null 2>&1
# get a list of databases
databases=`$MYSQL --user=$MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
  skipdb=0
  if [ "$SKIPDB" != "" ]; then
    for i in $SKIPDB
      do
        [ "$db" == "$i" ] && skipdb=1 || :
      done
  fi
  
  if [ "$skipdb" == "0" ]; then
    echo $db
    $MYSQLDUMP --force --opt --user=$MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWORD --databases $db | $GZIP -9 > "$MYSQL_BACKUP_DIR/$db.sql.gz"
  fi
done

