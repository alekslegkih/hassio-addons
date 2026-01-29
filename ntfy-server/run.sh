#!/bin/sh

set -e
set -o pipefail

CONFIG_DIR="/config"
CACHE_FILE="$CONFIG_DIR/cache.db"
AUTH_FILE="$CONFIG_DIR/auth.db"
NTFY_ETC_DIR="/etc/ntfy"
SERVER_CONFIG="$CONFIG_DIR/server.yml"

mkdir -p "$CONFIG_DIR"
mkdir -p "$NTFY_ETC_DIR"

[ -f "$NTFY_ETC_DIR/server.yml" ] && ! [ -L "$NTFY_ETC_DIR/server.yml" ] && rm -f "$NTFY_ETC_DIR/server.yml"
[ -f "$NTFY_ETC_DIR/client.yml" ] && ! [ -L "$NTFY_ETC_DIR/client.yml" ] && rm -f "$NTFY_ETC_DIR/client.yml"

[ ! -e "$NTFY_ETC_DIR/server.yml" ] && ln -sf "$SERVER_CONFIG" "$NTFY_ETC_DIR/server.yml"
[ ! -e "$NTFY_ETC_DIR/client.yml" ] && touch "$NTFY_ETC_DIR/client.yml"

if [ ! -f "$SERVER_CONFIG" ]; then
    cat > "$SERVER_CONFIG" << EOF
##==========================
# ntfy server configuration
##==========================

# Logging
# Possible values: trace, debug, info, warn, error
log-level: info

# Listen address for the HTTP
listen-http: ":8080"

# Cache (required for since= and poll)
cache-file: "$CACHE_FILE"
cache-duration: "72h"

# Authentication
auth-file: "$AUTH_FILE"
auth-default-access: "deny-all"

# Recommended for mobile clients
keepalive-interval: "45s"

# Message limits (do not increase if using mobile push)
message-size-limit: "4k"

# Enable if running behind a reverse proxy
behind-proxy: true

# Public URL (required for iOS, attachments, reverse proxy setups)
# base-url: "https://ntfy.example.com"
EOF
fi

exec ntfy serve --config="$SERVER_CONFIG" 
