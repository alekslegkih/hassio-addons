#!/usr/bin/with-contenv bashio
set -e

bashio::log.info "Loading backup configuration..."

# Function to validate configuration structure
validate_config() {
    local USER_CONFIG="$1"
    
    # Required fields
    local required_fields=(
        "general.timezone"
        "general.rsync_options" 
        "general.test_mode"
        "storage.label_backup"
        "storage.label_data"
        "storage.data_dir"
        "power.enable_power"
        "power.disc_switch"
        "notifications.enable_notifications"
        "notifications.notification_service"
        "notifications.success_message"
        "notifications.error_message"
    )
    
    local has_errors=false
    
    # Check fields
    for field in "${required_fields[@]}"; do
        local value=$(yq e ".$field" "$USER_CONFIG" 2>/dev/null)
        
        if [ "$value" = "null" ] || [ -z "$value" ]; then
            bashio::log.error "Missing required field: $field"
            has_errors=true
        elif [[ "$field" == *".test_mode" || "$field" == *".enable_power" || "$field" == *".enable_notifications" ]] && \
            [ "$value" != "true" ] && [ "$value" != "false" ]; then
            bashio::log.error "Invalid boolean value for $field: '$value' (should be 'true' or 'false')"
            has_errors=true
        fi
    done
    
    if [ "$has_errors" = true ]; then
        bashio::log.error "Configuration validation failed!"
        return 1
    fi
    
    bashio::log.info "Configuration validation passed"
    return 0
}

# Main configuration loading function
load_config() {
    local ADDON_SLUG="nc_user_files_backup"
    local DEFAULT_CONFIG="/etc/nc_backup/defaults.yaml"
    local CONFIG_DIR="/config"
    local USER_CONFIG="${CONFIG_DIR}/settings.yaml"

    # Create default settings if not exists
    if [ ! -f "$USER_CONFIG" ]; then
        bashio::log.notice "=== FIRST RUN DETECTED ==="
        
        if [ -f "$DEFAULT_CONFIG" ]; then
            cp "$DEFAULT_CONFIG" "$USER_CONFIG"
            bashio::log.info "Default settings created: $USER_CONFIG"
            bashio::log.warning "Please edit settings.yaml with your disk labels and restart addon"
            return 2
        else
            bashio::log.error "Default config not found: $DEFAULT_CONFIG"
            return 1
        fi
    else
        bashio::log.info "Using existing settings: $USER_CONFIG"
    fi
    
    # Validate configuration
    if ! validate_config "$USER_CONFIG"; then
        return 1
    fi

    # Load HA token from addon options
    if [ -r /data/options.json ]; then
        export HA_TOKEN=$(jq -r '.ha_token // ""' /data/options.json)
        if [ -z "$HA_TOKEN" ]; then
            bashio::log.error "HA Token is empty"
            return 1
        fi
        bashio::log.info "HA token loaded"
    else
        bashio::log.error "Cannot read /data/options.json"
        return 1
    fi

    # Load settings from user config
    export TIMEZONE=$(yq e '.general.timezone // "Europe/Moscow"' "$USER_CONFIG")
    export RSYNC_OPTIONS=$(yq e '.general.rsync_options // "-aHAX --delete"' "$USER_CONFIG")
    export TEST_MODE=$(yq e '.general.test_mode // false' "$USER_CONFIG")

    # Storage settings
    export LABEL_BACKUP=$(yq e '.storage.label_backup // "NC_backup"' "$USER_CONFIG")
    export LABEL_DATA=$(yq e '.storage.label_data // "Data"' "$USER_CONFIG")
    export DATA_DIR=$(yq e '.storage.data_dir // "data"' "$USER_CONFIG")

    # Power settings
    export ENABLE_POWER=$(yq e '.power.enable_power // false' "$USER_CONFIG")
    export DISC_SWITCH=$(yq e '.power.disc_switch // "usb_disk_power"' "$USER_CONFIG")

    # Notification settings
    export ENABLE_NOTIFICATIONS=$(yq e '.notifications.enable_notifications // true' "$USER_CONFIG")
    export NOTIFICATION_SERVICE=$(yq e '.notifications.notification_service // "telegram_cannel_system"' "$USER_CONFIG")
    export SUCCESS_MESSAGE=$(yq e '.notifications.success_message // "Nextcloud user files backup completed successfully!"' "$USER_CONFIG")
    export ERROR_MESSAGE=$(yq e '.notifications.error_message // "Nextcloud backup completed with errors!"' "$USER_CONFIG")

    # Set derived values
    export MOUNT_POINT_BACKUP="/mnt/$LABEL_BACKUP"
    export NEXTCLOUD_DATA_PATH="/mnt/$LABEL_DATA/$DATA_DIR"
    export DISC_SWITCH_SELECT="switch.${DISC_SWITCH}"
    
    # Set timezone for the container
    export TZ="$TIMEZONE"
    
    bashio::log.info "Configuration loaded successfully"
    bashio::log.debug "Backup disk: $MOUNT_POINT_BACKUP"
    bashio::log.debug "Data path: $NEXTCLOUD_DATA_PATH"
    
    return 0
}

# Execute configuration loading
load_config
CONFIG_EXIT_CODE=$?

if [ $CONFIG_EXIT_CODE -eq 2 ]; then
    bashio::log.warning "First run detected - addon will exit for configuration"
    exit 0
elif [ $CONFIG_EXIT_CODE -ne 0 ]; then
    bashio::log.error "Failed to load configuration - addon will exit"
    exit 1
fi

bashio::log.info "Backup configuration completed successfully"