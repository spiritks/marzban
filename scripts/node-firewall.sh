#!/usr/bin/env bash
set -euo pipefail
ADMIN_IP=${1:?Usage: sudo scripts/node-firewall.sh YOUR_ADMIN_PUBLIC_IP PANEL_PUBLIC_IP [XRAY_PORT] [NODE_API_PORT]}
PANEL_IP=${2:?Usage: sudo scripts/node-firewall.sh YOUR_ADMIN_PUBLIC_IP PANEL_PUBLIC_IP [XRAY_PORT] [NODE_API_PORT]}
XRAY_PORT=${3:-443}
NODE_API_PORT=${4:-62050}

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow from "$ADMIN_IP" to any port 22 proto tcp
ufw allow "$XRAY_PORT"/tcp
ufw allow from "$PANEL_IP" to any port "$NODE_API_PORT" proto tcp
ufw --force enable
ufw status verbose

echo "If your Marzban Node version uses another API port, rerun with that port as arg 4."
