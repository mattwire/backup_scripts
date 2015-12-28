#!/bin/bash
# Use PASSPHRASE if you want encryption
unset PASSPHRASE
nice -10 /usr/bin/duplicity remove-older-than 1Y file:///root/test_backup
nice -10 /usr/bin/duplicity --no-encryption --include="/var/www" --include="/root/staging" --exclude="**" / file:///root/test_backup --full-if-older-than 1M | mail -s "Nightly Backup Results (TEST)" $EMAIL
