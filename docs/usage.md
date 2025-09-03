Usage Guide
Quick Start with Bash

Navigate to the project root.
Run the quick hardening script (as root):sudo ./scripts/harden-quick.sh


Verify changes:grep PermitRootLogin /etc/ssh/sshd_config
# Should output: PermitRootLogin no



Ansible Automation

Install Ansible if not already: sudo apt install ansible.
Run the playbook:ansible-playbook ansible/playbook.yml -i localhost, -c local



Verification
Run the Python verifier:
python3 verif/verify.py

It will check compliance and output a report to logs/verification_report.txt.
Logs
Execution logs are saved in logs/ for auditing.
Testing on a Safe System
Use a VM or WSL to avoid affecting production systems. Revert changes by restoring backups from /etc/ (e.g., sshd_config.backup.*).
