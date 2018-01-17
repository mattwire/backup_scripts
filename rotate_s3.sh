#!/bin/bash
# This script rotates backups on S3 when they are stored in directories named with dates (eg. 2017-10-01)
# Arg1 (optional) = AWS Target (eg. s3://bucketname) (otherwise config file AWS_TARGET will be used
# Parameters in config file control frequency of backups to be kept.
#
# Note: All directories in the date format 2017-01-01 will be included, everything else will be excluded

# This script works by generating two lists:
#   EXISTING_BACKUPS: List of backups available on S3
#   KEEP_BACKUPS: List of backup dates we should keep

# Setup
CONF_DIR="/etc/backup"
CONF="$CONF_DIR/backup.cfg"

if [ ! -f "$CONF" ]; then
  echo "No config found in $CONF. Exiting"
  exit 1
fi

. "$CONF"

if [ "$ROTATE_S3" -ne 1 ]; then
  exit 0
fi

function rotate() {
  echo "Rotating: $AWS_TARGET"
  S3CMDLS="$S3 $S3_EXTRA_ARGS $S3_ACCESS ls $AWS_TARGET"
  S3CMDDEL="$S3 $S3_EXTRA_ARGS $S3_ACCESS --recursive --quiet del $AWS_TARGET"

  EXISTING_BACKUPS=""
  # Loop through each object from S3 and get list of EXISTING_BACKUPS
  while read -r line; do
    IFS=' ' read -r -a object <<< "$line"

    # Only act on DIR objects
    if [ "${object[0]}" == "DIR" ]; then
      IFS='/' read -r -a s3path <<< "${object[1]}"
      if [[ "${s3path[3]}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "${s3path[3]}" >/dev/null 2>&1; then
        EXISTING_BACKUPS="$EXISTING_BACKUPS ${s3path[3]}"
      fi
    fi
  done < <($S3CMDLS)

  # Check we have enough old backups
  EXISTING_COUNT=`echo "$EXISTING_BACKUPS" | wc -w`
  if [ $KEEP_MIN -gt $EXISTING_COUNT ]; then
    echo "Not enough backups to start rotating ($KEEP_MIN required, we have $EXISTING_COUNT)"
    return
  fi

  # Loop through EXISTING_BACKUPS and check for match in KEEP_BACKUPS
  # If we match, keep it, if not delete it.
  for backup in $EXISTING_BACKUPS; do
    if [[ ! "$KEEP_BACKUPS" =~ $backup ]]; then
      if [[ "$DRYRUN" -ne 0 ]] || [[ -z "$DRYRUN" ]]; then
        echo "DRYRUN: DELETE $S3CMDDEL/$backup"
      else
        echo "DELETE $backup/"
        $S3CMDDEL/$backup/
      fi
    fi
  done
}

# S3 command parameters
S3="/opt/s3cmd/s3cmd"
S3_EXTRA_ARGS="--ssl"
S3_ACCESS="--access_key=$AWS_WRITE_ACCESS_KEY --secret_key=$AWS_WRITE_SECRET_KEY"
DATE="`date +%Y-%m-%d`"

if [ -z $KEEP_DAILY ]; then
  echo ""
  echo "Error: You must specify KEEP_DAILY in the config file"
  echo ""
fi
if [ -z $KEEP_WEEKLY ]; then
  echo ""
  echo "Error: You must specify KEEP_WEEKLY in the config file"
  echo ""
fi
if [ -z $KEEP_MONTHLY ]; then
  echo ""
  echo "Error: You must specify KEEP_MONTHLY in the config file"
  echo ""
fi
if [ -z $KEEP_YEARLY ]; then
  echo ""
  echo "Error: You must specify KEEP_YEARLY in the config file"
  echo ""
fi

KEEP_MIN=$((KEEP_DAILY + KEEP_WEEKLY + KEEP_MONTHLY + KEEP_YEARLY))

# Generate KEEP_BACKUPS list (dates we should keep)
date=`date +%Y-%m-%d`
for (( day=0; day<"$KEEP_DAILY"; day++)); do
  KEEP_DATE=$(date -d "-$day days" +%Y-%m-%d)
  KEEP_BACKUPS="$KEEP_BACKUPS $KEEP_DATE"
done
for (( week=0; week<"$KEEP_WEEKLY"; week++)); do
  KEEP_DATE=$(date -d "$(date -d yesterday +%u) days ago -$week weeks" +%Y-%m-%d)
  KEEP_BACKUPS="$KEEP_BACKUPS $KEEP_DATE"
done
for (( month=0; month<"$KEEP_MONTHLY"; month++)); do
  KEEP_DATE=$(date -d "-$month months" +%Y-%m)"-01"
  KEEP_BACKUPS="$KEEP_BACKUPS $KEEP_DATE"
done
for (( year=0; year<"$KEEP_YEARLY"; year++)); do
  KEEP_DATE=$(date -d "-$year years" +%Y)"-01-01"
  KEEP_BACKUPS="$KEEP_BACKUPS $KEEP_DATE"
done

# Allow passing bucket as arg1
ARG1=$1
if [[ -z "$ARG1" ]]; then
  # Not specified, grab from config file
  AWS_TARGET=$AWS_TARGET
  rotate
  exit 0
elif [[ "$ARG1" =~ "s3://" ]]; then
  # Bucket specified, grab from arg1
  AWS_TARGET=$ARG1
  rotate
  exit 0
fi

AWS_TARGET_INCLUDE=$ARG1
if [ ! -f $ARG1 ]; then
  # Allow passing config file containing list of buckets as arg1
  AWS_TARGET_INCLUDE="$CONF_DIR/$ARG1"
fi
if [ ! -f $AWS_TARGET_INCLUDE ]; then
  echo -e ""
  echo -e "Error: Could not file an include file ($AWS_TARGET_INCLUDE)"
  echo -e ""
  exit 1;
else
  while read -r line; do
    if [[ "$line" =~ "s3://" ]]; then
      AWS_TARGET=$line
      rotate
    else
      echo "Malformed S3 target: $line"
    fi
  done <"$AWS_TARGET_INCLUDE"
fi
