#!/bin/sh
# Backup openmediavault datastore to external drive 

SRCDIR=omv:/media/datastore/
SRCNAME=openmediavault
DESTDIR=/mnt/backup/
SCRIPTDIR=`dirname $0`
RSYNC_EXCLUDE=$SCRIPTDIR/rsync-exclude

echo $SCRIPTDIR

if [ `whoami` != "root" ]; then
	echo "ERROR: This must be run as root. Exiting."
	exit 1
fi
if [ ! -f $RSYNC_EXCLUDE ]; then
	echo "ERROR: Can't find $RSYNC_EXCLUDE.  It should be in the same dir as this script. Exiting."
	exit 1
fi

echo "This script will backup $SRCNAME using rsync to an external drive."
echo "   NOTE: Files on destination will be deleted if they do not exist on source."
echo "   $SRCNAME source dir: $SRCDIR"
echo
read -p "Please type \"yes\" to confirm that you have mounted destination disk on /mnt/backup: " RETVAL
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
rsync -av --delete-during --exclude-from=$RSYNC_EXCLUDE $SRCDIR $DESTDIR
