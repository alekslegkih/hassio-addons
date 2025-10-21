#!/bin/bash
set -euo pipefail

# Load bashio
if [ -f /usr/lib/bashio/bashio.sh ]; then
    source /usr/lib/bashio/bashio.sh
else
    echo "Bashio not available"
    exit 1
fi

# Load logging functions and colors
source /etc/nc_backup/logging.sh

# =============================================================================
# Nextcloud User Files Backup Script for Home Assistant Addon
# =============================================================================

# Set timezone (уже установлен в cont-init.d, но на всякий случай)
export TZ="${TIMEZONE:-Europe/Moscow}"

# Function for Home Assistant API calls with token
ha_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"

    local url="http://homeassistant:8123/api/$endpoint"
    
    if [ -n "$data" ]; then
        curl -s -X "$method" \
            -H "Authorization: Bearer $HA_TOKEN" \
            -H "Content-Type: application/json" \
            --data "$data" \
            "$url"
    else
        curl -s -X "$method" \
            -H "Authorization: Bearer $HA_TOKEN" \
            -H "Content-Type: application/json" \
            "$url"
    fi
}

# Check if disk is mounted via local_mounts
is_disk_mounted() {
    local disk_label="$1"
    if mount | grep -q "/mnt/$disk_label"; then
        return 0
    else
        return 1
    fi
}

# --- Unified error/success handler
handle_final_result() {
    local success="$1"
    local error_msg="${2:-}"
    
    if [ "$success" = true ] && [ -z "$error_msg" ]; then
        FINAL_MSG="$SUCCESS_MESSAGE"
        FINAL_LOG="Backup script completed successfully!"
        EXIT_CODE=0
    else
        if [ -n "$error_msg" ]; then
            bashio::log.error "$error_msg"
            FINAL_MSG="$error_msg"
        else
            FINAL_MSG="$ERROR_MESSAGE"
        fi
        FINAL_LOG="Backup script failed!"
        EXIT_CODE=1
    fi
    
    bashio::log.info "$FINAL_LOG"
    
    # Send notification if enabled
    if [ "$ENABLE_NOTIFICATIONS" = "true" ]; then
        PAYLOAD=$(jq -n --arg msg "$FINAL_MSG" '{"message": $msg}')
        if ha_api_call "POST" "services/notify/$NOTIFICATION_SERVICE" "$PAYLOAD" > /dev/null; then
            bashio::log.info "Notification sent: $FINAL_MSG"
        else
            bashio::log.warning "Failed to send notification"
        fi
    else
        bashio::log.info "Notifications disabled"
    fi
    
    exit $EXIT_CODE
}

# --- Info header
print_header() {
    bashio::log.blue "-----------------------------------------------------"
    bashio::log.blue "Add-on: Nextcloud User Files Backup Dev"
    bashio::log.blue "      for Home Assistant"
    bashio::log.blue "-----------------------------------------------------"
    bashio::log.blue "System: $(uname -s) $(uname -r)"
    bashio::log.blue "Architecture: $(uname -m)"
    bashio::log.blue "Timezone: $TZ"
    bashio::log.blue "Backup disk: /mnt/$LABEL_BACKUP"
    bashio::log.blue "Data source: /mnt/$LABEL_DATA/$DATA_DIR"
    
    if [ "$ENABLE_POWER" = "true" ]; then
        bashio::log.blue "Power control: ENABLED"
        bashio::log.blue "Switch entity: $DISC_SWITCH_SELECT"
    else
        bashio::log.blue "Power control: DISABLED"
    fi
    
    if [ "$ENABLE_NOTIFICATIONS" = "true" ]; then
        bashio::log.blue "Notifications: ENABLED"
        bashio::log.blue "Service: $NOTIFICATION_SERVICE"
    else
        bashio::log.blue "Notifications: DISABLED"
    fi
    
    if [ "$TEST_MODE" = "true" ]; then
        bashio::log.red "Test mode: ACTIVE"
    else
        bashio::log.blue "Test mode: INACTIVE"
    fi
    
    bashio::log.blue "-----------------------------------------------------"
}

# =============================================================================
# MAIN BACKUP LOGIC
# =============================================================================

print_header

bashio::log.green "Starting user files backup"
bashio::log.green "Started: $(date)"

# --- Check Home Assistant API availability
bashio::log.info "Checking Home Assistant API connection..."
API_RESPONSE=$(ha_api_call "GET" "" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print('API OK' if 'message' in data else 'API Error')
except:
    print('API Error')
" 2>/dev/null || echo "API Error")

if [ "$API_RESPONSE" = "API OK" ]; then
    bashio::log.info "Home Assistant API connection successful"
else
    handle_final_result false "Home Assistant API connection failed"
fi

# --- Check if disks are mounted via local_mounts
bashio::log.info "Checking if backup disk is mounted..."
if ! is_disk_mounted "$LABEL_BACKUP"; then
    handle_final_result false "Backup disk '$LABEL_BACKUP' not mounted. Check localdisks configuration."
fi
bashio::log.info "Backup disk mounted: /mnt/$LABEL_BACKUP"

bashio::log.info "Checking if data disk is mounted..."
if ! is_disk_mounted "$LABEL_DATA"; then
    handle_final_result false "Data disk '$LABEL_DATA' not mounted. Check localdisks configuration."
fi
bashio::log.info "Data disk mounted: /mnt/$LABEL_DATA"

# --- Set paths (должны быть уже установлены в cont-init.d)
MOUNT_POINT_BACKUP="/mnt/$LABEL_BACKUP"
NEXTCLOUD_DATA_PATH="/mnt/$LABEL_DATA/$DATA_DIR"

# --- Verify backup disk is accessible
if [ ! -d "$MOUNT_POINT_BACKUP" ]; then
    handle_final_result false "Backup disk directory not accessible: $MOUNT_POINT_BACKUP"
fi
bashio::log.info "Backup disk accessible"

# --- Verify write permissions
if touch "$MOUNT_POINT_BACKUP/.write_test" 2>/dev/null; then
    rm -f "$MOUNT_POINT_BACKUP/.write_test"
    bashio::log.info "Backup disk ready for writing"
else
    handle_final_result false "No write permission on backup disk. Check disk permissions."
fi

# --- Verify Nextcloud data is accessible
if [ ! -d "$NEXTCLOUD_DATA_PATH" ]; then
    handle_final_result false "Nextcloud data not accessible. Please check data disk and data_dir setting."
fi
bashio::log.info "Nextcloud data accessible"

# --- Find all users from data directory
bashio::log.info "Getting user list from $NEXTCLOUD_DATA_PATH ..."
USERS=$(find "$NEXTCLOUD_DATA_PATH" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)

if [ -z "$USERS" ]; then
    handle_final_result false "No users found in Nextcloud data directory"
fi

USERS_LOG=$(echo "$USERS" | paste -sd ', ' -)
bashio::log.info "Found users: $USERS_LOG"

# --- Backup each user with files/ directory
SUCCESS=true
for user in $USERS; do
    SRC="$NEXTCLOUD_DATA_PATH/$user/files/"
    DST="$MOUNT_POINT_BACKUP/$user/"

    # Skip if user doesn't have files directory
    if [ ! -d "$SRC" ]; then
        bashio::log.info "User '$user' has no files directory — skipping"
        continue
    fi

    # Create destination directory if it doesn't exist
    mkdir -p "$DST"

    bashio::log.info "Starting backup for user: $user..."

    if [ "$TEST_MODE" = "true" ]; then
        # --- Simulation for testing
        bashio::log.blue "TEST MODE: Simulating copy (2 sec)..."
        sleep 2
        # Симулируем успешное копирование
        bashio::log.blue "TEST MODE: User $user backup simulation completed"
        FILE_COUNT_SIM=$(find "$SRC" -type f 2>/dev/null | wc -l || echo "0")
        bashio::log.blue "TEST MODE: Would copy approximately $FILE_COUNT_SIM files"
    else
        # --- Actual user files backup
        bashio::log.info "Copying from $SRC to $DST ..."
        if rsync $RSYNC_OPTIONS "$SRC" "$DST/"; then
            bashio::log.green "User $user backup completed successfully"
            
            # Additional info about copied data
            FILE_COUNT=$(find "$DST" -type f | wc -l)
            bashio::log.info "Files copied: $FILE_COUNT"
        else
            bashio::log.error "User $user backup failed"
            SUCCESS=false
        fi
    fi
done

# --- Power control logic (optional - only if enabled)
if [ "$ENABLE_POWER" = "true" ]; then
    bashio::log.info "Power control enabled - turning off backup disk power..."
    if ha_api_call "POST" "services/switch/turn_off" "$(jq -n --arg entity "$DISC_SWITCH_SELECT" '{entity_id: $entity}')" > /dev/null; then
        bashio::log.info "Backup disk power turned off"
    else
        bashio::log.warning "Failed to turn off backup disk power"
    fi
else
    bashio::log.info "Power control disabled - disk remains mounted"
fi

# --- Final result
if [ "$SUCCESS" = true ]; then
    handle_final_result true ""
else
    handle_final_result false ""
fi