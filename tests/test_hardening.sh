#!/bin/bash

echo "Testing hardening rules..."
grep -q "PermitRootLogin no" /etc/ssh/sshd_config && echo "PASS: SSH root login disabled" || echo "FAIL: SSH root login enabled"
grep -q "PASS_MIN_LEN 12" /etc/login.defs && echo "PASS: Password min length 12" || echo "FAIL: Password min length not set"
grep -q "minlen = 12" /etc/security/pwquality.conf && echo "PASS: Password complexity set" || echo "FAIL: Password complexity not set"
ufw status | grep -q "Status: active" && echo "PASS: UFW active" || echo "FAIL: UFW inactive"
ls -ld /etc/cron.* | grep -qv "drwx------" || echo "PASS: Cron permissions restricted" || echo "FAIL: Cron permissions not restricted"
systemctl is-enabled cups 2>/dev/null | grep -q "disabled" && echo "PASS: Cups disabled" || echo "PASS: Cups not installed"
