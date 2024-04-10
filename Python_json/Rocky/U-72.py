#!/usr/bin/python3
import json
import subprocess

def check_system_logging_policy():
    results = {
        "분류": "로그 관리",
        "코드": "U-72",
        "위험도": "하",
        "진단 항목": "정책에 따른 시스템 로깅 설정",
        "진단 결과": "N/A",  # 수동 확인 필요
        "현황": [],
        "대응방안": "로그 기록 정책 설정 및 보안 정책에 따른 로그 관리"
    }

    filename = "/etc/rsyslog.conf"
    expected_content = [
        "*.info;mail.none;authpriv.none;cron.none                /var/log/messages",
        "authpriv.*                                              /var/log/secure",
        "mail.*                                                  -/var/log/maillog",
        "cron.*                                                  /var/log/cron",
        "*.emerg                                                 :omusrmsg:*",
        "*.alert                                                 /dev/console",
        "*.emerg                                                 *"
    ]

    # Improved file existence check using subprocess.call() for compatibility
    file_exists = subprocess.call(['test', '-f', filename]) == 0

    if not file_exists:
        results["진단 결과"] = "취약"
        results["현황"].append(f"{filename} 파일이 존재하지 않습니다.")
    else:
        with open(filename, 'r') as file:
            file_contents = file.read()
        
        all_contents_found = all(any(line.strip() in file_contents for line in expected_content if line) for content in expected_content)

        if not all_contents_found:
            results["진단 결과"] = "취약"
            results["현황"].append(f"{filename} 파일의 내용이 기대한 설정과 일치하지 않습니다.")
        else:
            results["진단 결과"] = "양호"
            results["현황"].append(f"{filename} 파일의 내용이 정확합니다.")

    return results

def main():
    system_logging_policy_check_results = check_system_logging_policy()
    print(json.dumps(system_logging_policy_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
