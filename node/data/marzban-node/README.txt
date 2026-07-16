Place the Marzban Node client certificate here before starting the node:

- cert.pem

Copy it from the Marzban panel node-creation flow. Current Marzban Node uses this panel-provided client certificate via SSL_CLIENT_CERT_FILE; there is no separate ssl_key.pem to get from the panel.

Keep SERVICE_PORT accessible only from the panel server.
