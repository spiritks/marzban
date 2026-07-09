#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../panel"
TS=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="../backups/$TS"
mkdir -p "$BACKUP_DIR"

set -a
source .env
set +a

docker compose exec -T postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$BACKUP_DIR/postgres.sql"
tar -czf "$BACKUP_DIR/marzban-data.tgz" data/marzban .env docker-compose.yml Caddyfile

echo "Backup written to $BACKUP_DIR"
