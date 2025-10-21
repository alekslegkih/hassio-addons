#!/bin/bash
set -e

echo "=== Starting Nextcloud User Files Backup Addon ==="

# Load bashio
if [ -f /usr/lib/bashio/bashio.sh ]; then
    source /usr/lib/bashio/bashio.sh
else
    echo "Bashio not available"
    exit 1
fi

# Конфигурация уже загружена через /etc/cont-init.d/10-load-config.sh
# Проверяем что основные переменные установлены
if [ -z "${TIMEZONE:-}" ]; then
    bashio::log.error "Configuration not loaded. TIMEZONE is empty"
    exit 1
fi

bashio::log.info "Configuration verified, starting backup..."

# Start main backup script
exec /usr/local/bin/backup.sh