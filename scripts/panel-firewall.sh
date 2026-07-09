#!/usr/bin/env bash
set -euo pipefail
ADMIN_IP=${1:?Usage: sudo scripts/panel-firewall.sh YOUR_ADMIN_PUBLIC_IP}

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow from "$ADMIN_IP" to any port 22 proto tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
ufw status verbose
