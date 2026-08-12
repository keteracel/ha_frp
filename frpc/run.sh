#!/usr/bin/env sh
# Generate an frpc config from the add-on options and run it.
# Deliberately does NOT log the token and writes config to container-local /tmp
# (never /share, so other add-ons cannot read the secret).
set -eu

OPTS=/data/options.json
SERVER_ADDR=$(jq -r '.server_addr' "$OPTS")
SERVER_PORT=$(jq -r '.server_port' "$OPTS")
TOKEN=$(jq -r '.token' "$OPTS")
CUSTOM_DOMAIN=$(jq -r '.custom_domain' "$OPTS")
PROXY_NAME=$(jq -r '.proxy_name' "$OPTS")
LOCAL_PORT=$(jq -r '.local_port' "$OPTS")

for name in SERVER_ADDR TOKEN CUSTOM_DOMAIN PROXY_NAME; do
  eval "val=\$$name"
  if [ -z "$val" ] || [ "$val" = "null" ]; then
    echo "ERROR: required option '$name' is empty" >&2
    exit 1
  fi
done

CONF=/tmp/frpc.toml
cat > "$CONF" <<EOF
serverAddr = "${SERVER_ADDR}"
serverPort = ${SERVER_PORT}
auth.method = "token"
auth.token = "${TOKEN}"
transport.tls.enable = true
log.to = "console"
log.level = "info"

[[proxies]]
name = "${PROXY_NAME}"
type = "http"
customDomains = ["${CUSTOM_DOMAIN}"]
localIP = "127.0.0.1"
localPort = ${LOCAL_PORT}
transport.useEncryption = true
transport.useCompression = true
EOF

echo "Starting frpc: proxy '${PROXY_NAME}' -> ${CUSTOM_DOMAIN} via ${SERVER_ADDR}:${SERVER_PORT} (TLS on)"
exec frpc -c "$CONF"
