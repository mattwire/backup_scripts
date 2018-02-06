#!/bin/bash
# Backup files to a tar (gzipped) archive
#
# Arg1 = Name of tar file (date+.tar.gz will be appended)
# Arg2 = file containing list of files/dirs to include
# Arg3 (optional) = file containing list of files/dirs to exclude

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

if [ "$BACKUP_TAR" -ne 1 ]; then
  exit 0
fi

if [ $# -lt 2 ]; then
  echo -e ""
  echo -e "Error: You must specify tar filename."
  echo -e "Error: You must specify a file containing a list of files/dirs to include."
  echo -e "Optional: Specify a file containing a list of files/dirs to exclude as arg2."
  echo -e ""
  echo -e "Examples:"
  echo -e "  backup tar.include tar.exclude"
  echo -e "  backup /etc/backup/tar.include"
  echo -e ""
  exit 1;
fi;


# Get include/exclude files
DATE="`date +%Y-%m-%d_%H%M`"
TAR_NAME="$1_$DATE.tar.gz"
TAR_INCLUDE=$2
TAR_EXCLUDE=$3

if [ ! -f $TAR_INCLUDE ]; then
  TAR_INCLUDE="$CONF_DIR/$TAR_INCLUDE"
fi
if [ ! -f $TAR_INCLUDE ]; then
  echo -e ""
  echo -e "Error: Could not file an include file ($TAR_INCLUDE)"
  echo -e ""
  exit 1;
else
  TAR_EXTRA_ARGS="`/bin/cat $TAR_INCLUDE`"
fi

if [ ! -z $TAR_EXCLUDE ]; then
  if [ ! -f $TAR_EXCLUDE ]; then
    TAR_EXCLUDE="$CONF_DIR/$TAR_EXCLUDE"
  fi
  if [ ! -f $TAR_EXCLUDE ]; then
    echo -e ""
    echo -e "Error: Could not file an exclude file ($TAR_EXCLUDE)"
    echo -e ""
    exit 1;
  fi

  excludes=()    # start with an empty array
  for excl in `/bin/cat $TAR_EXCLUDE`; do    # for each extra argument...
    eval excludepath="$excl"
    wcount=`echo ${excludepath} | wc -w`
    if [ $wcount -gt 1 ]; then
      # eval expands wildcards into multiple separate files.
      # This adds each of those as a separate exclude
      for excl2 in $excludepath; do
        excludes+=(--exclude "$excl2")
      done
    else
      # No wildcards were expanded, just add one exclude
      excludes+=(--exclude "$excludepath")    # add an exclude to the array
    fi
  done

  TAR_EXCLUDES="${excludes[@]}"
  TAR_EXTRA_ARGS="$TAR_EXTRA_ARGS"
fi

TAR_CMD="tar -cpzf $STAGING_DIR/$TAR_NAME $TAR_EXCLUDES $TAR_EXTRA_ARGS"

$TAR_CMD 2> /dev/null
