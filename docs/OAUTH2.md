# OAuth2/OIDC protection for Marzban Panel

This scaffold protects the Marzban web panel with oauth2-proxy in front of Marzban:

Browser -> Cloudflare Tunnel / HTTPS -> Caddy -> oauth2-proxy -> Marzban

Important: this is an external SSO gate plus a local login bridge. Upstream Marzban still uses its own JWT-based admin auth and does not expose native OIDC admin login settings in the standard `.env.example`. After OAuth succeeds, the bridge calls Marzban's local `/api/admin/token` with the configured `SUDO_USERNAME`/`SUDO_PASSWORD`, writes the returned JWT to dashboard `localStorage`, and redirects to `/dashboard/?sso=1`. This skips the visible Marzban password form without patching the upstream Marzban image.

## Public vs protected paths

Protected by OAuth2/OIDC:

- `/dashboard/`
- `/marzban-login/*`
- `/api/admin/*`
- all other panel/API paths not explicitly marked public

Public for client provisioning:

- `/oauth2/*` callback and oauth2-proxy endpoints
- `/sub*` subscription/provisioning endpoint

If you change `XRAY_SUBSCRIPTION_PATH` from `sub` to another value, update `panel/Caddyfile` too.

## Identity provider settings

Create an OIDC/OAuth2 application in your IdP with:

- Type: confidential web application
- Redirect/callback URI: `https://panel.example.com/oauth2/callback`, or `https://panel.example.com:8443/oauth2/callback` when the admin panel is exposed on a non-standard HTTPS port.
- Scopes: `openid email profile` by default. If your IdP requires additional scopes, add them to `OAUTH2_PROXY_SCOPE` in `panel/.env` and in the IdP application settings.
- Grant type: authorization code

Then edit `panel/.env`:

- `SUDO_USERNAME` and `SUDO_PASSWORD` for the local Marzban dashboard token bridge. Use a strong random password; it is not typed by browser users.
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

- tunnel service URL: `https://127.0.0.1:443`, `https://127.0.0.1:PANEL_HTTPS_PORT`, or `http://127.0.0.1:80`, depending on how you terminate TLS
- public hostname: `panel.example.com`

If the public admin panel uses a non-standard HTTPS port, include the same `:PORT` in `OAUTH2_PROXY_REDIRECT_URL` and in the IdP callback URI, for example `https://panel.example.com:8443/oauth2/callback`.

For a stricter setup you can also use Cloudflare Access in front of this, but avoid double-login complexity unless needed.

User Xray/VLESS/REALITY traffic should continue going directly to node VPS addresses, not through Cloudflare Tunnel.
