#!/usr/bin/env bash
set -e

GPG_KEY_ID=$(cat /etc/wal-e.d/env/WALE_GPG_KEY_ID)
gpg --import /etc/wal-e.d/gpg_pub.key
trust_gpg.exp $GPG_KEY_ID
