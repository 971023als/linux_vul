#!/usr/bin/python3
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
    print_as_md(system_logging_policy_check_results)

if __name__ == "__main__":
    main()
