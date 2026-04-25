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

import sys

# Python 3.7 이상에서 표준 출력의 인코딩을 UTF-8로 설정
if sys.stdout.encoding != 'UTF-8':
    sys.stdout.reconfigure(encoding='utf-8')

def check_access_control_files():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-18",
        "위험도": "상",
        "진단 항목": "접속 IP 및 포트 제한",
        "진단 결과": "",
        "현황": [],
        "대응방안": "특정 호스트에 대한 IP 주소 및 포트 제한 설정"
    }

    hosts_deny_path = '/etc/hosts.deny'
    hosts_allow_path = '/etc/hosts.allow'

    hosts_deny_exists = check_file_exists_and_content(hosts_deny_path, 'ALL: ALL')
    hosts_allow_exists = check_file_exists_and_content(hosts_allow_path, 'ALL: ALL')

    if not hosts_deny_exists:
        results["진단 결과"] = "취약"
        results["현황"].append(f"{hosts_deny_path} 파일에 'ALL: ALL' 설정이 없거나 파일이 없습니다.")
    elif hosts_allow_exists:
        results["진단 결과"] = "취약"
        results["현황"].append(f"{hosts_allow_path} 파일에 'ALL: ALL' 설정이 있습니다.")
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("적절한 IP 및 포트 제한 설정이 확인되었습니다.")

    return results

def check_file_exists_and_content(file_path, search_string):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                if search_string.lower() in line.lower() and not line.strip().startswith('#'):
                    return True
    except FileNotFoundError:
        pass
    return False

def main():
    results = check_access_control_files()
    print_as_md(results)

if __name__ == "__main__":
    main()
