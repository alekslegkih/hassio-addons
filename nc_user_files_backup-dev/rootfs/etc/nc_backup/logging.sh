#!/bin/bash
# Этот скрипт загружается вручную, поэтому используем bash

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $1"; }
log_green() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') ${GREEN}$1${NC}"; }
log_red() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') ${RED}$1${NC}"; }
log_blue() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') ${BLUE}$1${NC}"; }
log_yellow() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') ${YELLOW}$1${NC}"; }