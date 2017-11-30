#!/usr/bin/env bash
set -e

GPG_KEY_ID=$(cat /etc/wal-e.d/env/WALE_GPG_KEY_ID)
sudo -u postgres gpg --import /etc/wal-e.d/gpg_pub.key
sudo -u postgres trust_gpg.exp $GPG_KEY_ID

# Initialize first full backup. Incremental WALs are configured in postgresql.conf
sudo -u postgres /usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-push /var/lib/postgresql/data
# To be run by postgres user
# Scheduling bacups weekly on Saturdays 2 AM
echo "0 2 * * 6 cd /home/postgres && sudo -u postgres /usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-push /var/lib/postgresql/data >> /cron.log 2>&1" | crontab -
cron
