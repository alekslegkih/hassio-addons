#!/bin/sh
# Gotify Server Add-on for Home Assistant

set -e

CONFIG_DIR="/config"
LOG_FILE="$CONFIG_DIR/gotify.log"
CONFIG_FILE="$CONFIG_DIR/config.yml"
DB_FILE="$CONFIG_DIR/gotify.db"
IMAGES_DIR="$CONFIG_DIR/images"
DEFAULT_ICON_URL="https://raw.githubusercontent.com/gotify/server/master/ui/public/static/defaultapp.png"
DEFAULT_ICON="$IMAGES_DIR/defaultapp.png"

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[GOTIFY] $timestamp $1"
    echo "$message" | tee -a "$LOG_FILE"
}

log_section() {
    log "========================================"
    log "$1"
    log "========================================"
}

log_section "Starting Gotify Server Add-on"

log "Initializing directories..."
mkdir -p "$IMAGES_DIR"

log "Configuration paths:"
log "  • Config:      $CONFIG_FILE"
log "  • Database:    $DB_FILE"
log "  • Images:      $IMAGES_DIR"
log "  • Logs:        $LOG_FILE"

if [ ! -f "$DEFAULT_ICON" ]; then
    log "Downloading default application icon..."
    if wget -q --timeout=10 "$DEFAULT_ICON_URL" -O "$DEFAULT_ICON"; then
        log "✓ Icon downloaded successfully"
    else
        log "⚠  Failed to download icon, creating empty placeholder"
        echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" | \
            base64 -d > "$DEFAULT_ICON"
    fi
else
    log "✓ Icon already exists"
fi

if [ ! -f "$CONFIG_FILE" ]; then
    log "Creating default configuration..."
    cat > "$CONFIG_FILE" << EOF
server:
  listenaddr: "0.0.0.0"
  port: 80
  uploadedimagesdir: "$IMAGES_DIR"
  responseheaders:
    X-Frame-Options: "DENY"
  cors:
    alloworigins:
      - "*"
    allowmethods:
      - "GET"
      - "POST"
      - "OPTIONS"
  log:
    level: info
database: 
  dialect: sqlite3
  connection: "$DB_FILE"
# Users are created via web interface
EOF
    log "✓ Configuration created"
else
    log "✓ Using existing configuration"
fi

log_section "System Information"
log "Gotify version: $(/usr/bin/gotify-server --version 2>/dev/null | grep -o 'version [0-9.]\+' || echo 'unknown')"
log "Database size: $(du -h "$DB_FILE" 2>/dev/null | cut -f1 || echo 'not created')"
log "Icons count: $(find "$IMAGES_DIR" -type f -name '*.png' 2>/dev/null | wc -l)"
log "Port mapping: 80 → 8486"

log_section "Starting Server"
log "Web UI: http://[HOST]:[PORT:8486]"
log "External URL: https://iot.alsite.ru"
log "All logs duplicated to: $LOG_FILE"

trap 'log "Received termination signal"; exit 0' TERM INT

exec /usr/bin/gotify-server --config="$CONFIG_FILE" 2>&1 | tee -a "$LOG_FILE"