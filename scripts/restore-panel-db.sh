#!/usr/bin/env bash
set -euo pipefail
DB_FILE=${1:?Usage: scripts/restore-panel-db.sh /path/to/db.sqlite3}
cd "$(dirname "$0")/../panel"

if [ ! -f "$DB_FILE" ]; then
  echo "SQLite database file not found: $DB_FILE" >&2
  exit 1
fi

mkdir -p data/marzban
if [ -f data/marzban/db.sqlite3 ]; then
  cp data/marzban/db.sqlite3 "data/marzban/db.sqlite3.before-restore.$(date +%Y%m%d-%H%M%S)"
fi
cp "$DB_FILE" data/marzban/db.sqlite3

echo "Restored db.sqlite3. Restart the marzban container before using the panel."
