#!/bin/sh
set -e

CONFIG_DIR="/config"
CONFIG_FILE="$CONFIG_DIR/config.yml"
DB_FILE="$CONFIG_DIR/gotify.db"
IMAGES_DIR="$CONFIG_DIR/images"
DEFAULT_ICON_URL="https://raw.githubusercontent.com/gotify/server/master/ui/public/static/defaultapp.png"
DEFAULT_ICON="$IMAGES_DIR/defaultapp.png"

mkdir -p "$IMAGES_DIR"

if [ ! -f "$DEFAULT_ICON" ]; then
    wget -q "$DEFAULT_ICON_URL" -O "$DEFAULT_ICON" || true
fi

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
fi

exec /usr/bin/gotify-server --config="$CONFIG_FILE"
