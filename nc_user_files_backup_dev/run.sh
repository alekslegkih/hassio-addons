#!/usr/bin/with-contenv bashio

echo "=== Starting Nextcloud User Files Backup Addon ==="

# Все инициализации уже выполнены в cont-init.d
# Просто запускаем основной скрипт бэкапа
exec /usr/local/bin/backup.sh