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

# Load configuration from cont-init script
if [ -f /etc/cont-init.d/10-load-config.sh ]; then
    bashio::log.info "Loading configuration..."
    # Source the configuration script to set variables
    source /etc/cont-init.d/10-load-config.sh
else
    bashio::log.error "Configuration script not found"
    exit 1
fi

# Check if configuration was loaded
if [ -z "${TIMEZONE:-}" ]; then
    bashio::log.error "Configuration failed to load. TIMEZONE is empty"
    exit 1
fi

bashio::log.info "Configuration loaded successfully, starting backup..."

# Start main backup script
exec /usr/local/bin/backup.sh