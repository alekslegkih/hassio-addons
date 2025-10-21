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

# Load configuration
if [ -f /etc/nc_backup/config.sh ]; then
    source /etc/nc_backup/config.sh
else
    bashio::log.error "Config file not found: /etc/nc_backup/config.sh"
    exit 1
fi

load_config
CONFIG_EXIT_CODE=$?

if [ $CONFIG_EXIT_CODE -eq 2 ]; then
    exit 0
elif [ $CONFIG_EXIT_CODE -ne 0 ]; then
    bashio::log.error "Failed to load configuration"
    exit 1
fi

# Start main backup script
exec /usr/local/bin/backup.sh