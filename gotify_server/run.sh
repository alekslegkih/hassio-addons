#!/bin/sh
# Gotify Server Add-on for Home Assistant

set -e

# === КОНСТАНТЫ ===
CONFIG_DIR="/config"
LOG_FILE="$CONFIG_DIR/gotify.log"
CONFIG_FILE="$CONFIG_DIR/config.yml"
DB_FILE="$CONFIG_DIR/gotify.db"
IMAGES_DIR="$CONFIG_DIR/images"
DEFAULT_ICON_URL="https://raw.githubusercontent.com/gotify/server/master/ui/public/static/defaultapp.png"
DEFAULT_ICON="$IMAGES_DIR/defaultapp.png"

# === ФУНКЦИИ ЛОГИРОВАНИЯ ===
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[GOTIFY] $timestamp $1"
    echo "$message" | tee -a "$LOG_FILE"
}

log_section() {
    log "========================================="
    log "$1"
    log "========================================="
}

# === НАЧАЛО ===
log_section "Запуск Gotify Add-on"

# === ПРОВЕРКА И СОЗДАНИЕ СТРУКТУРЫ ===
log "Создание структуры каталогов..."
mkdir -p "$IMAGES_DIR"
log "Каталоги созданы:"
log "  Конфиг:     $CONFIG_DIR"
log "  База:       $DB_FILE"
log "  Иконки:     $IMAGES_DIR"
log "  Логи:       $LOG_FILE"

# === ДЕФОЛТНАЯ ИКОНКА ===
if [ ! -f "$DEFAULT_ICON" ]; then
    log "Загрузка дефолтной иконки..."
    if wget -q "$DEFAULT_ICON_URL" -O "$DEFAULT_ICON"; then
        log "Иконка загружена: $DEFAULT_ICON"
    else
        log "ВНИМАНИЕ: Не удалось загрузить иконку, создаем пустую"
        echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" | \
            base64 -d > "$DEFAULT_ICON" || true
    fi
else
    log "Иконка уже существует: $DEFAULT_ICON"
fi

# === ДЕФОЛТНЫЙ КОНФИГ ===
if [ ! -f "$CONFIG_FILE" ]; then
    log "Создание конфигурации по умолчанию..."
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
    log "Конфиг создан: $CONFIG_FILE"
else
    log "Используется существующий конфиг: $CONFIG_FILE"
fi

# === ИНФОРМАЦИЯ О СИСТЕМЕ ===
log_section "Информация о системе"
log "Версия Gotify: $(/usr/bin/gotify-server --version 2>/dev/null | head -1 || echo 'unknown')"
log "Размер базы: $(du -h "$DB_FILE" 2>/dev/null | cut -f1 2>/dev/null || echo '0B')"
log "Файлов в images/: $(ls -1 "$IMAGES_DIR" 2>/dev/null | wc -l)"
log "Порт: 80 → 8486 (наружу)"

# === ЗАПУСК ===
log_section "Запуск Gotify Server"
log "Команда: /usr/bin/gotify-server --config=\"$CONFIG_FILE\""
log "Web UI: http://[HOST]:[PORT:8486]"
log "Логи будут дублироваться в: $LOG_FILE"

# Захватываем сигналы для чистого завершения
trap 'log "Получен сигнал завершения"; exit 0' TERM INT

# Запускаем Gotify с логированием в файл
exec /usr/bin/gotify-server --config="$CONFIG_FILE" 2>&1 | tee -a "$LOG_FILE"