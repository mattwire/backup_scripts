#!/bin/sh
# Rsync backup to external drive

SRCDIR=/mnt2/store/
SRCNAME=`hostname`
DESTDIR=/mnt/usb/
SCRIPTDIR=`dirname $0`
RSYNC_EXCLUDE=/etc/backup/rsync.exclude
RSYNC_INCLUDE=/etc/backup/rsync.include

if [ `whoami` != "root" ]; then
  echo "ERROR: This must be run as root. Exiting."
  exit 1
fi
if [ ! -f $RSYNC_EXCLUDE ]; then
  echo "ERROR: Can't find $RSYNC_EXCLUDE.  It should be in the same dir as this script. Exiting."
  exit 1
fi
if [ ! -f $RSYNC_INCLUDE ]; then
  echo "ERROR: Can't find $RSYNC_INCLUDE.  It should be in the same dir as this script. Exiting."
  exit 1
fi

echo "This script will backup $SRCNAME using rsync to an external drive."
echo "   NOTE: Files on destination will be deleted if they do not exist on source."
echo "   Dirs that will be included:"
/bin/cat "$RSYNC_INCLUDE"
echo ""
read -p "Please type \"yes\" to confirm that you have mounted destination disk on $DESTDIR: " RETVAL
if [ "$RETVAL" != "yes" ]; then
  echo "Exiting."
  exit 1
fi

# Check mountpoint
mountpoint -q $DESTDIR
if [ $? -gt 0 ]; then
  echo "ERROR: $DESTDIR is not a mount point!. Exiting"
  exit 1
fi

# Now do the backup
rsync -avAX --delete-during --recursive --exclude-from=$RSYNC_EXCLUDE --files-from=$RSYNC_INCLUDE / $DESTDIR
