#!/bin/bash
set -e
../backup_scripts/dump_all_etc.sh
../backup_scripts/backup_mysql.sh
./backup_to_s3.sh
