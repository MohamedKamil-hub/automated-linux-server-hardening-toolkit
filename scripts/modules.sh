#!/bin/bash

# Logging function
log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" | tee -a logs/hardening.log
}

# Backup file function
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        log "Backed up $file to $backup"
    else
        log "Sorry, $file does not exist, skipping backup"
    fi
}

# Ensure SSHD config key-value (idempotent)
ensure_sshd_config() {
    local key=$1
    local value=$2
    local file="/etc/ssh/sshd_config"
    
    backup_file "$file"
    
    if grep -q "^$key" "$file"; then
        sed -i "s/^$key.*/$key $value/" "$file"
        log "Updated $key to $value in $file"
    else
        echo "$key $value" >> "$file"
        log "Appended $key $value to $file"
    fi
    
    systemctl restart ssh
    log "Restarted sshd service"
}
