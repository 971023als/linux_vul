#!/usr/bin/python3
import os
import subprocess
import json


def print_as_md(results: dict):
    """진단 결과를 Markdown 테이블 형식으로 출력."""
    code   = results.get("코드",     results.get("code", "U-??"))
    item   = results.get("진단 항목", results.get("diagnosisItem", "진단항목"))
    cat    = results.get("분류",     results.get("category", ""))
    risk   = results.get("위험도",   results.get("riskLevel", ""))
    result = results.get("진단 결과", results.get("diagnosisResult", ""))
    status = results.get("현황",     results.get("status", []))
    sol    = results.get("대응방안", results.get("solution", ""))

    if isinstance(status, list):
        status = " / ".join(status) if status else ""

    print(f"# {code}: {item}")
    print("")
    print("| 항목 | 내용 |")
    print("|------|------|")
    print(f"| 분류 | {cat} |")
    print(f"| 코드 | {code} |")
    print(f"| 위험도 | {risk} |")
    print(f"| 진단항목 | {item} |")
    print(f"| 진단결과 | {result} |")
    print(f"| 현황 | {status} |")
    print(f"| 대응방안 | {sol} |")


def check_ssh_telnet_services():
    results = {
        "분류": "서비스 관리",
        "코드": "U-60",
        "위험도": "중",
        "진단 항목": "ssh 원격접속 허용",
        "진단 결과": "",
        "현황": [],
        "대응방안": "SSH 사용 권장, Telnet 및 FTP 사용하지 않도록 설정"
    }

    # Checking SSH service status for both possible service names
    ssh_active = False
    for service_name in ['ssh', 'sshd']:
        try:
            ssh_status = subprocess.run(['systemctl', 'is-active', service_name], stdout=subprocess.PIPE, universal_newlines=True)
            if ssh_status.stdout.strip() == 'active':
                results["현황"].append(f"SSH 서비스({service_name}) 활성화")
                ssh_active = True
                break
        except FileNotFoundError:
            continue  # Try the next service name if systemctl is not found
    if not ssh_active:
        results["현황"].append("SSH 서비스 비활성화")

    # Check for Telnet service
    try:
        telnet_check = subprocess.run(['pgrep', '-f', 'telnetd'], stdout=subprocess.PIPE, universal_newlines=True)
        telnet_active = bool(telnet_check.stdout.strip())
    except FileNotFoundError:
        telnet_active = False  # Assume not active if pgrep is not available
    results["현황"].append("Telnet 서비스 활성화" if telnet_active else "Telnet 서비스 비활성화")

    # Check for FTP service
    try:
        ftp_check = subprocess.run(['pgrep', '-f', 'ftpd'], stdout=subprocess.PIPE, universal_newlines=True)
        ftp_active = bool(ftp_check.stdout.strip())
    except FileNotFoundError:
        ftp_active = False  # Assume not active if pgrep is not available
    results["현황"].append("FTP 서비스 활성화" if ftp_active else "FTP 서비스 비활성화")

    # Determine overall security status
    if ssh_active and not telnet_active and not ftp_active:
        results["진단 결과"] = "양호"
    else:
        results["진단 결과"] = "취약"

    return results

def main():
    security_check_results = check_ssh_telnet_services()
    print_as_md(security_check_results)

if __name__ == "__main__":
    main()
