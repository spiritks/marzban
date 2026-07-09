# Security checklist

- Use SSH keys only; disable password login.
- Restrict SSH to admin public IP.
- Keep panel HTTPS only.
- Use a strong Marzban admin password.
- Restrict node API to the panel public IP only.
- Do not expose Postgres publicly.
- Back up `.env`, database and node TLS files securely.
- Rotate users/subscription links when leaked.
- Keep Docker host and containers updated.
- Avoid hosting panel and all nodes at one provider if resilience matters.
