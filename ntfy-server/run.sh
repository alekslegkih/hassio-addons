#!/bin/sh
# ntfy Server Add-on for Home Assistant

set -e
set -o pipefail

CONFIG_DIR="/config"
LOG_FILE="$CONFIG_DIR/ntfy.log"
CACHE_FILE="$CONFIG_DIR/cache.db"
AUTH_FILE="$CONFIG_DIR/auth.db"
NTFY_ETC_DIR="/etc/ntfy"
SERVER_CONFIG="$CONFIG_DIR/server.yml"

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp $1" | tee -a "$LOG_FILE"
}

log_section() {
    log "========================================="
    log "$1"
    log "========================================="
}

log_section "Starting ntfy Add-on"

mkdir -p "$CONFIG_DIR"

# Ensure CLI tools use our config
mkdir -p "$NTFY_ETC_DIR"

# Remove default files if they exist (Alpine package creates them)
[ -f "$NTFY_ETC_DIR/server.yml" ] && ! [ -L "$NTFY_ETC_DIR/server.yml" ] && rm -f "$NTFY_ETC_DIR/server.yml"
[ -f "$NTFY_ETC_DIR/client.yml" ] && ! [ -L "$NTFY_ETC_DIR/client.yml" ] && rm -f "$NTFY_ETC_DIR/client.yml"

# Link our config for CLI compatibility
[ ! -e "$NTFY_ETC_DIR/server.yml" ] && ln -sf "$SERVER_CONFIG" "$NTFY_ETC_DIR/server.yml"
[ ! -e "$NTFY_ETC_DIR/client.yml" ] && touch "$NTFY_ETC_DIR/client.yml"

# Generate config if missing
if [ ! -f "$SERVER_CONFIG" ]; then
    log "Generating default configuration..."
    cat > "$SERVER_CONFIG" << EOF
##==========================
# ntfy server configuration
##==========================
# Listen address for the HTTP
listen-http: ":8080"

# Public URL (required for iOS, attachments, reverse proxy setups)
# base-url: "https://ntfy.example.com"

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
EOF
    log "Configuration created: $SERVER_CONFIG"
else
    log "Using existing configuration: $SERVER_CONFIG"
fi

log_section "Launching ntfy Server"
log "Web UI: http://[HOST]:[PORT:8487]"
log "Logs: $LOG_FILE"

trap 'log "Termination signal received"; exit 0' TERM INT

exec ntfy serve --config="$SERVER_CONFIG" 2>&1 | tee -a "$LOG_FILE"