#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../panel"

read -rp "Admin username: " USERNAME
read -rsp "Admin password: " PASSWORD
echo

docker compose exec -T marzban marzban cli admin create --sudo --username "$USERNAME" --password "$PASSWORD"
