#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../panel"
TS=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="../backups/$TS"
mkdir -p "$BACKUP_DIR"

if [ -f data/marzban/db.sqlite3 ]; then
  cp data/marzban/db.sqlite3 "$BACKUP_DIR/db.sqlite3"
else
  echo "Warning: data/marzban/db.sqlite3 not found; backing up data directory only" >&2
fi

tar -czf "$BACKUP_DIR/marzban-data.tgz" data/marzban .env docker-compose.yml Caddyfile

echo "Backup written to $BACKUP_DIR"
