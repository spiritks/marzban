# OAuth2/OIDC protection for Marzban Panel

This scaffold protects the Marzban web panel with oauth2-proxy in front of Marzban:

Browser -> Cloudflare Tunnel / HTTPS -> Caddy -> oauth2-proxy -> Marzban

Important: this is an external SSO gate. Marzban's own admin login still exists behind OAuth2 because upstream Marzban does not currently expose native OIDC admin login settings in the standard `.env.example`. So the operator first authenticates with the OIDC provider, then logs in to Marzban as admin.

## Public vs protected paths

Protected by OAuth2/OIDC:

- `/dashboard/`
- `/api/admin/*`
- all other panel/API paths not explicitly marked public

Public for client provisioning:

- `/oauth2/*` callback and oauth2-proxy endpoints
- `/sub*` subscription/provisioning endpoint

If you change `XRAY_SUBSCRIPTION_PATH` from `sub` to another value, update `panel/Caddyfile` too.

## Identity provider settings

Create an OIDC/OAuth2 application in your IdP with:

- Type: confidential web application
- Redirect/callback URI: `https://panel.example.com/oauth2/callback`
- Scopes: `openid email profile` by default. If your IdP requires additional scopes, add them to `OAUTH2_PROXY_SCOPE` in `panel/.env` and in the IdP application settings.
- Grant type: authorization code

Then edit `panel/.env`:

- `OAUTH2_PROXY_OIDC_ISSUER_URL`
- `OAUTH2_PROXY_CLIENT_ID`
- `OAUTH2_PROXY_CLIENT_SECRET`
- `OAUTH2_PROXY_REDIRECT_URL`
- `OAUTH2_PROXY_SCOPE`
- `OAUTH2_PROXY_EMAIL_DOMAINS`

For stricter access, replace `OAUTH2_PROXY_EMAIL_DOMAINS=*` with exact allowed domains or explicit email addresses, for example:

- `OAUTH2_PROXY_EMAIL_DOMAINS=example.com`
- or `OAUTH2_PROXY_EMAIL_DOMAINS=admin@example.com,ops@example.com`

## Cookie secret

`OAUTH2_PROXY_COOKIE_SECRET` must be a base64 value representing exactly 32 random bytes.

Generate it with:

```bash
python3 - <<'PY'
import secrets, base64
print(base64.urlsafe_b64encode(secrets.token_bytes(32)).decode())
PY
```

The generated `panel/.env` in this project already has a random cookie secret; `.env.example` only has a placeholder.

## Cloudflare Tunnel usage

Cloudflare Tunnel should point to Caddy on the panel server, not directly to Marzban:

- tunnel service URL: `https://127.0.0.1:443` or `http://127.0.0.1:80`, depending on how you terminate TLS
- public hostname: `panel.example.com`

For a stricter setup you can also use Cloudflare Access in front of this, but avoid double-login complexity unless needed.

User Xray/VLESS/REALITY traffic should continue going directly to node VPS addresses, not through Cloudflare Tunnel.
