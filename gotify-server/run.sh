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
    local message="$timestamp $1"
    echo "$message" | tee -a "$LOG_FILE"
}

log_section() {
    log "========================================="
    log "$1"
    log "========================================="
}

log_section "Starting Gotify Add-on"

log "Creating directory structure..."
mkdir -p "$IMAGES_DIR"
log "Directories created:"
log "  Config:     $CONFIG_DIR"
log "  Database:   $DB_FILE"
log "  Icons:      $IMAGES_DIR"
log "  Logs:       $LOG_FILE"

if [ ! -f "$DEFAULT_ICON" ]; then
    log "Downloading default icon..."
    if wget -q "$DEFAULT_ICON_URL" -O "$DEFAULT_ICON"; then
        log "Icon downloaded: $DEFAULT_ICON"
    else
        log "WARNING: Failed to download icon; creating a placeholder"
        echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" | \
            base64 -d > "$DEFAULT_ICON" || true
    fi
else
    log "Icon already exists: $DEFAULT_ICON"
fi

if [ ! -f "$CONFIG_FILE" ]; then
    log "Generating default configuration..."
    cat > "$CONFIG_FILE" << EOF
server:
  listenaddr: "0.0.0.0"
  port: 80
  uploadedimagesdir: "$IMAGES_DIR"
  responseheaders:
    X-Frame-Options: "DENY"
  log:
    level: info
database: 
  dialect: sqlite3
  connection: "$DB_FILE"
EOF
    log "Configuration created: $CONFIG_FILE"
else
    log "Using existing configuration: $CONFIG_FILE"
fi

log_section "System Information"
log "Gotify version: $(/usr/bin/gotify-server --version 2>/dev/null | head -1 || echo 'unknown')"
log "Database size: $(du -h "$DB_FILE" 2>/dev/null | cut -f1 2>/dev/null || echo '0B')"
log "Number of files in images/: $(find "$IMAGES_DIR" -type f 2>/dev/null | wc -l)"
log "Gotify listens on container port 80"
log "Home Assistant maps it to external port 8486"

log_section "Launching Gotify Server"
log "Command: /usr/bin/gotify-server --config=\"$CONFIG_FILE\""
log "Web UI: http://[HOST]:[PORT:8486]"
log "Logs will be duplicated to: $LOG_FILE"

trap 'log "Termination signal received"; exit 0' TERM INT

exec /usr/bin/gotify-server --config="$CONFIG_FILE" 2>&1 | tee -a "$LOG_FILE"