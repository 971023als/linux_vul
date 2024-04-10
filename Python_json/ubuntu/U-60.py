#!/usr/bin/python3
import os
import subprocess
import json

def check_ssh_telnet_services():
    results = {
        "분류": "서비스 관리",
        "코드": "U-60",
        "위험도": "중",
        "진단 항목": "ssh 원격접속 허용",
        "진단 결과": "",
        "현황": {"SSH 서비스 상태": "", "Telnet 서비스 상태": "", "FTP 서비스 상태": ""},
        "대응방안": "SSH 사용 권장, Telnet 및 FTP 사용하지 않도록 설정"
    }

    # Checking SSH service status for both possible service names
    for service_name in ['ssh', 'sshd']:
        try:
            ssh_status = subprocess.run(['systemctl', 'is-active', service_name], stdout=subprocess.PIPE, universal_newlines=True)
            if ssh_status.stdout.strip() == 'active':
                results["현황"]["SSH 서비스 상태"] = "활성화"
                ssh_active = True
                break
        except FileNotFoundError:
            continue  # Try the next service name if systemctl is not found
    else:
        results["현황"]["SSH 서비스 상태"] = "비활성화"
        ssh_active = False

    # Check for Telnet service
    try:
        telnet_check = subprocess.run(['pgrep', '-f', 'telnetd'], stdout=subprocess.PIPE, universal_newlines=True)
        telnet_active = bool(telnet_check.stdout.strip())
    except FileNotFoundError:
        telnet_active = False  # Assume not active if pgrep is not available
    results["현황"]["Telnet 서비스 상태"] = "활성화" if telnet_active else "비활성화"

    # Check for FTP service
    try:
        ftp_check = subprocess.run(['pgrep', '-f', 'ftpd'], stdout=subprocess.PIPE, universal_newlines=True)
        ftp_active = bool(ftp_check.stdout.strip())
    except FileNotFoundError:
        ftp_active = False  # Assume not active if pgrep is not available
    results["현황"]["FTP 서비스 상태"] = "활성화" if ftp_active else "비활성화"

    # Determine overall security status
    if ssh_active and not telnet_active and not ftp_active:
        results["진단 결과"] = "양호"
    else:
        results["진단 결과"] = "취약"

    return results

def main():
    security_check_results = check_ssh_telnet_services()
    print(json.dumps(security_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
