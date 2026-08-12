#!/usr/bin/env sh
# Generate an frpc config from the add-on options and run it.
# Deliberately does NOT log the token and writes config to container-local /tmp
# (never /share, so other add-ons cannot read the secret).
set -eu

OPTS=/data/options.json
SERVER_ADDR=$(jq -r '.server_addr' "$OPTS")
SERVER_PORT=$(jq -r '.server_port' "$OPTS")
TOKEN=$(jq -r '.token' "$OPTS")
CLIENT_SECRET=$(jq -r '.client_secret // ""' "$OPTS")
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

# Client identity = the subdomain label of the custom domain (e.g. "smith" from
# smith.example.com). Sent with the per-client secret so the server can authenticate this
# client and enforce it only claims its own domain.
CLIENT_ID=$(echo "$CUSTOM_DOMAIN" | cut -d. -f1)

CONF=/tmp/frpc.toml
{
  echo "serverAddr = \"${SERVER_ADDR}\""
  echo "serverPort = ${SERVER_PORT}"
  echo "user = \"${CLIENT_ID}\""
  echo "auth.method = \"token\""
  echo "auth.token = \"${TOKEN}\""
  echo "transport.tls.enable = true"
  echo "log.to = \"console\""
  echo "log.level = \"info\""
  if [ -n "$CLIENT_SECRET" ] && [ "$CLIENT_SECRET" != "null" ]; then
    echo "metadatas.secret = \"${CLIENT_SECRET}\""
  fi
  echo ""
  echo "[[proxies]]"
  echo "name = \"${PROXY_NAME}\""
  echo "type = \"http\""
  echo "customDomains = [\"${CUSTOM_DOMAIN}\"]"
  echo "localIP = \"127.0.0.1\""
  echo "localPort = ${LOCAL_PORT}"
  echo "transport.useEncryption = true"
  echo "transport.useCompression = true"
} > "$CONF"

echo "Starting frpc: proxy '${PROXY_NAME}' -> ${CUSTOM_DOMAIN} via ${SERVER_ADDR}:${SERVER_PORT} (TLS on)"
exec frpc -c "$CONF"
