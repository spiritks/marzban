# Marzban + Xray-core multi-node Docker scaffold

This project contains a production-oriented scaffold for:

- Central Marzban panel with SQLite and HTTPS reverse proxy.
- OAuth2/OIDC gate for the admin panel via oauth2-proxy.
- Multiple remote Marzban Node servers running Xray-core through Marzban Node.
- VLESS + REALITY provisioning through Marzban subscription links.
- Backup, firewall and operational helper scripts.

The files intentionally use placeholders such as `panel.example.com`, `de1.example.com`, and `YOUR_ADMIN_IP`. Replace them before deployment.

## Directory layout

- `panel/` — central Marzban panel stack.
- `node/` — reusable stack for each Xray/Marzban node.
- `scripts/` — install, firewall, backup and validation helpers.
- `docs/` — implementation runbook and user provisioning notes.

## Required servers

Recommended minimum:

- 1 control server for Marzban Panel: Ubuntu 22.04/24.04, 2 vCPU, 2 GB RAM.
- 1+ node servers: Ubuntu 22.04/24.04, 1 vCPU, 1 GB RAM each.

DNS records to create:

- `panel.example.com` -> panel server IP
- `de1.example.com` -> node 1 IP
- `nl1.example.com` -> node 2 IP
- etc.

## Deployment summary

1. Copy this project to the panel server.
2. Edit `panel/.env` from `panel/.env.example`, including OIDC settings documented in `docs/OAUTH2.md`.
3. Run `sudo scripts/install-docker-ubuntu.sh` if Docker is not installed.
4. Run `cd panel && docker compose up -d`.
5. Create admin user with `../scripts/create-admin.sh`.
6. Copy `node/` to every node server.
7. Edit `node/.env` on each node.
8. Run `cd node && docker compose up -d` on each node.
9. In Marzban UI: add nodes, configure VLESS REALITY inbound(s), create users, issue subscription links.

Read `docs/RUNBOOK.md` before production deployment.
