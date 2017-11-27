#!/bin/sh
# This script relies on a script configured on remote host:
# /backup/scp_remote_backup.sh:
# #!/bin/sh
# scp -r -f /backup/`date --date "-1 day" +%Y-%m-%d`/
# Configured in /root/.ssh/authorized_keys:
# command="/backup/scp_remote_backup.sh",no-port-forwarding,no-x11-forwarding,no-agent-forwarding ssh-rsa key...

DEST=/mnt/backup/webhosting/mjwcoaa2
scp -v -r root@mjwcoaa2.miniserver.com: $DEST

echo "Backup finished: Destination contents:"
ls $DEST
