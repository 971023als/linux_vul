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
        "*.info;mail.none;authpriv.none;cron.none /var/log/messages",
        "authpriv.* /var/log/secure",
        "mail.* /var/log/maillog",
        "cron.* /var/log/cron",
        "*.alert /dev/console",
        "*.emerg *"
    ]

    # 로깅 파일 존재 여부 확인
    if not subprocess.run(['test', '-e', filename]).returncode == 0:
        results["진단 결과"] = "취약"
        results["현황"].append(f"{filename} 파일이 존재하지 않습니다.")
    else:
        # 로깅 파일 내용 확인
        with open(filename, 'r') as file:
            file_contents = file.read().splitlines()

        for content in expected_content:
            if content not in file_contents:
                results["진단 결과"] = "취약"
                results["현황"].append(f"{filename} 파일의 내용이 잘못되었습니다.")
                break

        if results["진단 결과"] != "취약":
            results["진단 결과"] = "양호"
            results["현황"].append(f"{filename} 파일의 내용이 정확합니다.")

    return results

def main():
    system_logging_policy_check_results = check_system_logging_policy()
    # JSON으로 변환하고, ensure_ascii=False 옵션을 사용하여 UTF-8로 인코딩된 문자열을 출력합니다.
    print(json.dumps(system_logging_policy_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
