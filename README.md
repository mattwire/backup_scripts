# Host Backup Scripts

Copyright MJW Consulting 2018
https://www.mjwconsult.co.uk

## Introduction
This is a collection of scripts for automating host backups with the minimum of setup.

## Scripts
### backup_mysql.sh
This script creates a dump of all (or a list of) databases from the local MYSQL server.

### backup_tar.sh
This script creates a gzipped tar archive containing the contents as defined in tar.include and tar.exclude.

The config files should contain one entry per line and may contain wildcards.

### check_requirements.sh
This is a simple helper script designed to help check that everything is configured correctly.

### dest_s3.sh
This allows you to PUT or SYNC files/directories to an Amazon S3 bucket

### dir_staging.sh
This manages the staging directory.

Specifically it creates the directory and allows it to be cleaned at the start or end (before rotate) of run.sh

### rotate_s3.sh
This allows you to rotate one or more buckets on Amazon S3.

### run.sh
This can be used as a "master" script to run multiple of the above.  It is controlled by backup.cfg

## Configuration
Config files should be copied from conf/ to either /etc/backup/ or ~/.mjwbackup/

Edit backup.cfg to get started.

## Installing s3cmd
### For VPS
```
cd /opt
git clone https://github.com/s3tools/s3cmd.git
```

### For shared server
#### Clone latest version of s3cmd
```
git clone https://github.com/s3tools/s3cmd.git
cd s3cmd
```

#### Install locally
```
python setup.py install --user
mkdir -p ~/bin
cp s3cmd ~/bin
cp -R S3 ~/bin
```

#### Remove s3 source
```
cd ../
rm -r s3cmd
```

## cPanel/WHM
We use the WHM backup system to create the backups and store them in `/backup/{yyyy-mm-dd}`. Then we use backup_scripts (specifically dest_s3.sh) to sync the contents of /backup up to an Amazon S3 bucket. Rotating backups is done via rotate_s3.sh on another server (but could be triggered from the cpanel server too).

1. Enable the WHM backups to save to `/backup` with system and account backups. Daily, retention 3 days.
1. Install backup_scripts to `/opt/backup` from https://github.com/mattwire/backup_scripts (and s3cmd to `/opt/s3cmd`).
1. Copy postcpbackup from `/opt/backup/helpers/postcpbackup` to `/usr/local/cpanel/scripts/postcpbackup` to automatically trigger after cpanel backups complete.
