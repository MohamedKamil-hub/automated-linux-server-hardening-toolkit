#!/bin/bash

# Must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as the supreme user root (use sudo)"
    exit 1
fi

# Source modules
source ./scripts/modules.sh

log "Starting quick hardening script"

# Disable root login via SSH
ensure_sshd_config "PermitRootLogin" "no"

# Password policies (e.g., enforce min length)
backup_file "/etc/login.defs"
sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 12/' /etc/login.defs
log "Set a secure password minimum length to 12"

# Password complexity
backup_file "/etc/security/pwquality.conf"
if grep -q "^minlen" /etc/security/pwquality.conf; then
    sed -i 's/^minlen.*/minlen = 12/' /etc/security/pwquality.conf
else
    echo "minlen = 12" >> /etc/security/pwquality.conf
fi
log "Set password complexity: minimum length 12"

# Firewall using iptables (for Parrot OS)
# Allow SSH if not already allowed
if ! iptables -C INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null; then
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    log "Added iptables rule to allow SSH"
else
    log "SSH rule already exists in iptables"
fi

# Set default policies safely
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

log "Firewall rules applied using iptables"

# Restrict cron permissions
chmod -R go-rwx /etc/cron.*
log "Restricted cron permissions"

# User permissions (remove unnecessary suid bits)
find / -perm -4000 -not -path "/usr/bin/sudo" -exec chmod -s {} \; 2>/dev/null
log "Removed unnecessary SUID bits"

# Disable unused services (example: cups)
systemctl disable cups 2>/dev/null || log "Cups service not found, skipping"
log "Disabled cups service"

log "Quick hardening complete"
