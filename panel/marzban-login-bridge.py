#!/usr/bin/env python3
"""OAuth-to-Marzban dashboard login bridge."""

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from html import escape
from urllib.parse import parse_qs, urlencode, urlparse
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
import json
import os

LISTEN_HOST = os.environ.get("MARZBAN_LOGIN_BRIDGE_HOST", "127.0.0.1")
LISTEN_PORT = int(os.environ.get("MARZBAN_LOGIN_BRIDGE_PORT", "4190"))
MARZBAN_API_BASE = os.environ.get("MARZBAN_LOGIN_BRIDGE_API_BASE", "http://127.0.0.1:8000/api")
ADMIN_USERNAME = os.environ.get("MARZBAN_LOGIN_BRIDGE_ADMIN_USERNAME") or os.environ.get("SUDO_USERNAME")
ADMIN_PASSWORD = os.environ.get("MARZBAN_LOGIN_BRIDGE_ADMIN_PASSWORD") or os.environ.get("SUDO_PASSWORD")
DASHBOARD_PATH = os.environ.get("DASHBOARD_PATH", "/dashboard/")


def html_response(title: str, body: str) -> bytes:
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{escape(title)}</title>
</head>
<body>{body}</body>
</html>
""".encode("utf-8")


def safe_redirect_target(raw: str | None) -> str:
    if not raw:
        return DASHBOARD_PATH
    parsed = urlparse(raw)
    if parsed.scheme or parsed.netloc:
        return DASHBOARD_PATH
    dashboard_root = DASHBOARD_PATH.rstrip("/")
    if parsed.path != dashboard_root and not parsed.path.startswith(dashboard_root + "/"):
        return DASHBOARD_PATH
    return raw


def token_from_marzban() -> str:
    if not ADMIN_USERNAME or not ADMIN_PASSWORD:
        raise RuntimeError("MARZBAN_LOGIN_BRIDGE_ADMIN_USERNAME/MARZBAN_LOGIN_BRIDGE_ADMIN_PASSWORD or SUDO_USERNAME/SUDO_PASSWORD are not configured")

    body = urlencode({"username": ADMIN_USERNAME, "password": ADMIN_PASSWORD}).encode("utf-8")
    req = Request(
        f"{MARZBAN_API_BASE.rstrip('/')}/admin/token",
        data=body,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        method="POST",
    )
    with urlopen(req, timeout=10) as response:
        payload = json.loads(response.read().decode("utf-8"))
    token = payload.get("access_token")
    if not token:
        raise RuntimeError("Marzban token endpoint did not return access_token")
    return token


class Handler(BaseHTTPRequestHandler):
    server_version = "marzban-login-bridge/1.0"

    def log_message(self, fmt: str, *args) -> None:
        print("%s - - [%s] %s" % (self.address_string(), self.log_date_time_string(), fmt % args), flush=True)

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path not in ("/", "/login", "/marzban-login", "/marzban-login/"):
            self.send_error(404)
            return

        qs = parse_qs(parsed.query)
        rd = safe_redirect_target(qs.get("rd", [DASHBOARD_PATH])[0])
        separator = "&" if "?" in rd else "?"
        rd_with_marker = f"{rd}{separator}sso=1"

        try:
            token = token_from_marzban()
        except (HTTPError, URLError, TimeoutError, RuntimeError, json.JSONDecodeError) as exc:
            body = html_response(
                "Marzban login bridge failed",
                "<h1>Marzban login bridge failed</h1>"
                "<p>External OAuth succeeded, but the bridge could not obtain a Marzban dashboard token.</p>"
                f"<pre>{escape(str(exc))}</pre>",
            )
            self.send_response(502)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return

        body = html_response(
            "Opening Marzban dashboard",
            "<p>Opening Marzban dashboard…</p>"
            "<script>"
            f"localStorage.setItem('token', {json.dumps(token)});"
            f"window.location.replace({json.dumps(rd_with_marker)});"
            "</script>"
            f"<noscript><p>JavaScript is required. After enabling it, open <a href={json.dumps(rd_with_marker)}>the dashboard</a>.</p></noscript>",
        )
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    httpd = ThreadingHTTPServer((LISTEN_HOST, LISTEN_PORT), Handler)
    print(f"Marzban login bridge listening on http://{LISTEN_HOST}:{LISTEN_PORT}", flush=True)
    httpd.serve_forever()
