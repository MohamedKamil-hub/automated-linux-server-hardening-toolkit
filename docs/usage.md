# Usage Guide

## Quick Start with Bash
1. Navigate to the project root.
2. Run the quick hardening script (as root):
sudo ./scripts/harden-quick.sh
3. Verify changes:
grep PermitRootLogin /etc/ssh/sshd_config
