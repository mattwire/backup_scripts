#!/bin/bash
set -e
./dump_all_etc.sh
./dump_all_mysql_db.sh
./backup_to_s3.sh
