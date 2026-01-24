#!/bin/sh

CONFIG_DIR="/addon_configs/gotify_server"
CONFIG_FILE="$CONFIG_DIR/config.yml"
DB_FILE="$CONFIG_DIR/gotify.db"
IMAGES_DIR="$CONFIG_DIR/images"

mkdir -p "$IMAGES_DIR"

# Конфиг (если нет)
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
    echo "Config created: $CONFIG_FILE"
fi

# Иконка (если нет)
if [ ! -f "$IMAGES_DIR/defaultapp.png" ]; then
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" | \
        base64 -d > "$IMAGES_DIR/defaultapp.png"
    echo "Default icon created"
fi

# Проверяем что есть
echo "=== Current state ==="
ls -la "$CONFIG_DIR/"
echo "====================="

exec /usr/bin/gotify-server --config="$CONFIG_FILE"