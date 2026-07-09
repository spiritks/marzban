#!/usr/bin/env bash
set -euo pipefail
SQL_FILE=${1:?Usage: scripts/restore-panel-db.sh /path/to/postgres.sql}
cd "$(dirname "$0")/../panel"
set -a
source .env
set +a

docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$SQL_FILE"
