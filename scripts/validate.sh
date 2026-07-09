#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for f in \
  "$ROOT/panel/docker-compose.yml" \
  "$ROOT/node/docker-compose.yml" \
  "$ROOT/scripts/install-docker-ubuntu.sh" \
  "$ROOT/scripts/panel-firewall.sh" \
  "$ROOT/scripts/node-firewall.sh" \
  "$ROOT/scripts/create-admin.sh" \
  "$ROOT/scripts/backup-panel.sh" \
  "$ROOT/scripts/restore-panel-db.sh" \
  "$ROOT/docs/OAUTH2.md"; do
  test -f "$f" || { echo "Missing $f" >&2; exit 1; }
done

bash -n "$ROOT"/scripts/*.sh
python3 -m json.tool "$ROOT/panel/data/marzban/xray_config.json" >/dev/null

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  cp "$ROOT/panel/.env.example" "$ROOT/panel/.env.validation"
  (cd "$ROOT/panel" && docker compose --env-file .env.validation config >/dev/null)
  rm -f "$ROOT/panel/.env.validation"
  cp "$ROOT/node/.env.example" "$ROOT/node/.env.validation"
  (cd "$ROOT/node" && docker compose --env-file .env.validation config >/dev/null)
  rm -f "$ROOT/node/.env.validation"
else
  echo "Docker compose not found; skipped compose rendering validation."
fi

echo "Validation OK"
