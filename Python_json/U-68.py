#!/usr/bin/python3
import subprocess
import os
import json

def check_login_message():
    results = {
        "분류": "서비스 관리",
        "코드": "U-68",
        "위험도": "하",
        "진단 항목": "로그온 시 경고 메시지 제공",
        "진단 결과": "",  # 초기 값 설정하지 않음
        "현황": [],
        "대응방안": "서버 및 주요 서비스(Telnet, FTP, SMTP, DNS)에 로그온 메시지 설정"
    }

    message_found = False  # Assume no login message found initially

    # Check /etc/motd for login message
    if os.path.exists('/etc/motd'):
        with open('/etc/motd', 'r') as file:
            if file.read().strip():
                message_found = True

    # Check for /etc/issue.net for Telnet and FTP services
    if os.path.exists('/etc/issue.net'):
        with open('/etc/issue.net', 'r') as file:
            if file.read().strip():
                message_found = True

    # Additional checks for FTP service configurations
    ftp_configs = ['/etc/vsftpd.conf', '/etc/proftpd/proftpd.conf', '/etc/pure-ftpd/conf/WelcomeMsg']
    for config in ftp_configs:
        if os.path.exists(config):
            with open(config, 'r') as file:
                content = file.read().strip()
                if 'ftpd_banner' in content or 'ServerIdent' in content or 'WelcomeMsg' in content:
                    message_found = True

    # SMTP service configuration check in sendmail.cf
    if os.path.exists('/etc/sendmail.cf'):
        with open('/etc/sendmail.cf', 'r') as file:
            if 'GreetingMessage' in file.read():
                message_found = True

    if message_found:
        results["진단 결과"] = "양호"
        results["현황"].append("로그온 메시지가 적절히 설정되어 있습니다.")
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("일부 또는 모든 서비스에 로그온 메시지가 설정되어 있지 않습니다.")

    # Note for DNS service configuration check
    results["현황"].append("DNS 배너의 경우 '/etc/named.conf' 또는 '/var/named' 파일을 수동으로 점검하세요.")

    return results

def main():
    login_message_check_results = check_login_message()
    print(json.dumps(login_message_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
