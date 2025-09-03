import subprocess
import sys

def run_command(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True).strip()
    except subprocess.CalledProcessError:
        return None

def check_sshd_root_login():
    output = run_command("grep '^PermitRootLogin' /etc/ssh/sshd_config")
    return "PermitRootLogin no" in output if output else False

def check_password_min_len():
    output = run_command("grep '^PASS_MIN_LEN' /etc/login.defs")
    return "PASS_MIN_LEN 12" in output if output else False

def check_password_complexity():
    output = run_command("grep '^minlen' /etc/security/pwquality.conf")
    return "minlen = 12" in output if output else False

def check_ufw_status():
    output = run_command("ufw status")
    return "Status: active" in output if output else False

def check_cron_permissions():
    output = run_command("ls -ld /etc/cron.* | grep -v 'drwx------'")
    return not output

def check_suid_bits():
    output = run_command("find / -perm -4000 2>/dev/null")
    return not output

def check_cups_disabled():
    output = run_command("systemctl is-enabled cups")
    return output == "disabled" if output else True

checks = {
    "SSH Root Login Disabled": check_sshd_root_login(),
    "Password Min Length 12": check_password_min_len(),
    "Password Complexity Minlen 12": check_password_complexity(),
    "UFW Firewall Active": check_ufw_status(),
    "Cron Permissions Restricted": check_cron_permissions(),
    "No Unnecessary SUID Bits": check_suid_bits(),
    "Cups Service Disabled": check_cups_disabled(),
}

print("Verification Report:")
for name, passed in checks.items():
    status = "PASS" if passed else "FAIL"
    print(f"- {name}: {status}")

with open("logs/verification_report.txt", "w") as f:
    for name, passed in checks.items():
        status = "PASS" if passed else "FAIL"
        f.write(f"{name}: {status}\n")

print("\nReport saved to logs/verification_report.txt")
