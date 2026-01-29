#!/bin/bash

# --- Чтение настроек из options.json ---
DEVICE=""
MOUNTPOINT="/data/media"
FRIENDLY_NAME="HAOS-DLNA"
ENABLE_SUBTITLES="yes"

if [ -f /data/options.json ]; then
  DEVICE=$(jq -r '.device // empty' /data/options.json)
  MOUNTPOINT=$(jq -r '.mountpoint // "/data/media"' /data/options.json)
  FRIENDLY_NAME=$(jq -r '.friendly_name // "HAOS-DLNA"' /data/options.json)
  ENABLE_SUBTITLES=$(jq -r '.enable_subtitles // "yes"' /data/options.json)
fi

# --- Обновление конфига minidlna ---
CONFIG="/etc/minidlna/minidlna.conf"

# Подменяем значения
sed -i "s|^log_level=.*|log_level=${LOG_LEVEL}|" "$CONFIG"
sed -i "s|^friendly_name=.*|friendly_name=${FRIENDLY_NAME}|" "$CONFIG"
sed -i "s|^enable_subtitles=.*|enable_subtitles=${ENABLE_SUBTITLES}|" "$CONFIG"

# Убедимся, что media_dir указывает на правильную папку
sed -i "s|^media_dir=.*|media_dir=${MOUNTPOINT}|" "$CONFIG"

# --- Запуск сервера ---
exec minidlnad -f "$CONFIG" -d