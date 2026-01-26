#!/bin/sh
# ntfy Server Add-on for Home Assistant
# Note: TLS/SSL is intentionally not configured here.
# Home Assistant Supervisor handles HTTPS termination.

set -e

CONFIG_DIR="/config"
LOG_FILE="$CONFIG_FILE/ntfy.log"  # ❌ ОШИБКА! Исправлено ниже
CACHE_FILE="$CONFIG_DIR/cache.db"
NTFY_ETC_DIR="/etc/ntfy"
SERVER_CONFIG="$CONFIG_DIR/server.yml"

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

# 🔧 Исправление: LOG_FILE должен быть внутри CONFIG_DIR
LOG_FILE="$CONFIG_DIR/ntfy.log"

log "Ensuring config directory exists..."
mkdir -p "$CONFIG_DIR"

# --- Debug: состояние /etc/ntfy до очистки ---
log "🔍 Inspecting /etc/ntfy BEFORE cleanup:"
if [ -d "$NTFY_ETC_DIR" ]; then
    ls -la "$NTFY_ETC_DIR" 2>/dev/null | while read line; do log "  $line"; done
else
    log "  /etc/ntfy does not exist yet"
fi

# --- Удаление дефолтных файлов (если они обычные файлы) ---
if [ -f "$NTFY_ETC_DIR/server.yml" ] && ! [ -L "$NTFY_ETC_DIR/server.yml" ]; then
    log "🗑️ Removing default $NTFY_ETC_DIR/server.yml (regular file)"
    rm -f "$NTFY_ETC_DIR/server.yml"
else
    if [ -L "$NTFY_ETC_DIR/server.yml" ]; then
        log "🔗 Found symlink at $NTFY_ETC_DIR/server.yml — keeping it"
    elif [ ! -e "$NTFY_ETC_DIR/server.yml" ]; then
        log "📄 $NTFY_ETC_DIR/server.yml does not exist — will create symlink"
    else
        log "⚠️ Unexpected state for $NTFY_ETC_DIR/server.yml — skipping removal"
    fi
fi

if [ -f "$NTFY_ETC_DIR/client.yml" ] && ! [ -L "$NTFY_ETC_DIR/client.yml" ]; then
    log "🗑️ Removing default $NTFY_ETC_DIR/client.yml (regular file)"
    rm -f "$NTFY_ETC_DIR/client.yml"
fi

# --- Создание symlink и client.yml ---
mkdir -p "$NTFY_ETC_DIR"

if [ ! -e "$NTFY_ETC_DIR/server.yml" ]; then
    log "🔗 Creating symlink: $NTFY_ETC_DIR/server.yml → $SERVER_CONFIG"
    ln -sf "$SERVER_CONFIG" "$NTFY_ETC_DIR/server.yml"
else
    log "✅ $NTFY_ETC_DIR/server.yml already exists — skipping symlink creation"
fi

if [ ! -e "$NTFY_ETC_DIR/client.yml" ]; then
    log "📄 Creating empty $NTFY_ETC_DIR/client.yml"
    touch "$NTFY_ETC_DIR/client.yml"
else
    log "✅ $NTFY_ETC_DIR/client.yml already exists"
fi

# --- Debug: состояние /etc/ntfy после настройки ---
log "🔍 Inspecting /etc/ntfy AFTER setup:"
ls -la "$NTFY_ETC_DIR" 2>/dev/null | while read line; do log "  $line"; done

# --- Генерация конфига сервера (если отсутствует) ---
if [ ! -f "$SERVER_CONFIG" ]; then
    log "⚙️ Generating default configuration..."
    cat > "$SERVER_CONFIG" << EOF
# ntfy server configuration
listen-http: ":8080"
# web-root: "-"   # <-- раскомментируй позже, чтобы отключить UI
cache-file: "$CACHE_FILE"
cache-duration: "72h"
auth-file: /config/auth.db
auth-default-access: "deny-all"
EOF
    log "✅ Configuration created: $SERVER_CONFIG"
else
    log "✅ Using existing configuration: $SERVER_CONFIG"
fi

log_section "System Information"
log "Cache file: $CACHE_FILE"
log "ntfy listens on container port 80"
log "Home Assistant maps it to external port 8487"

log_section "Launching ntfy Server"
log "Web UI: http://[HOST]:[PORT:8487]"
log "API endpoint: http://[HOST]:[PORT:8487]/<topic>"
log "Logs will be duplicated to: $LOG_FILE"

trap 'log "Termination signal received"; exit 0' TERM INT

exec ntfy serve --config="$SERVER_CONFIG" 2>&1 | tee -a "$LOG_FILE"