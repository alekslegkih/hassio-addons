#!/bin/sh
# ntfy Server Add-on for Home Assistant
# Note: TLS/SSL is intentionally not configured here.
# Home Assistant Supervisor handles HTTPS termination.

set -e

CONFIG_DIR="/config"
LOG_FILE="$CONFIG_DIR/ntfy.log"
CONFIG_FILE="$CONFIG_DIR/server.yml"

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$timestamp $1"
    echo "$message" | tee -a "$LOG_FILE"
}

log_section() {
    log "========================================="
    log "$1"
    log "========================================="
}

log_section "Starting ntfy Add-on"

log "Ensuring config directory exists..."
mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    log "Generating default configuration..."
    cat > "$CONFIG_FILE" << EOF
# ntfy server configuration
listen-http: ":8080"
# web-root: "-"   # <-- раскомментируй позже, чтобы отключить UI
cache-file: /config/cache.db
cache-duration: "72h"
auth-file: /config/auth.db
auth-default-access: "deny-all"
EOF
    log "Configuration created: $CONFIG_FILE"
else
    log "Using existing configuration: $CONFIG_FILE"
fi

log_section "System Information"
log "ntfy version: $(ntfy 2>/dev/null | head -1 || echo 'unknown')"
log "Cache file: /config/cache.db"
log "ntfy listens on container port 8080"
log "Home Assistant maps it to external port 8487"

log_section "Launching ntfy Server"
log "Command: ntfy serve --config=\"$CONFIG_FILE\""
log "Web UI: http://[HOST]:[PORT:8487]"
log "API endpoint: http://[HOST]:[PORT:8487]/<topic>"
log "Logs will be duplicated to: $LOG_FILE"

trap 'log "Termination signal received"; exit 0' TERM INT

exec ntfy serve --config="$CONFIG_FILE" 2>&1 | tee -a "$LOG_FILE"