#!/bin/sh

CONFIG_DIR="/config"
CONFIG_FILE="$CONFIG_DIR/config.yml"
DB_FILE="$CONFIG_DIR/gotify.db"
IMAGES_DIR="$CONFIG_DIR/images"

mkdir -p "$IMAGES_DIR"

# Конфиг
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << EOF
server:
  listenaddr: "0.0.0.0"
  port: 80
  uploadedimagesdir: "$IMAGES_DIR"
database: 
  dialect: sqlite3
  connection: "$DB_FILE"
EOF
    echo "Config created in /config"
fi

# Иконка
if [ ! -f "$IMAGES_DIR/defaultapp.png" ]; then
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" | \
        base64 -d > "$IMAGES_DIR/defaultapp.png"
fi

# === ЗАПУСК ===
echo "Starting Gotify"
echo "Config: $CONFIG_FILE"
echo "DB: $DB_FILE"
echo "Images: $IMAGES_DIR"

exec /usr/bin/gotify-server --config="$CONFIG_FILE"