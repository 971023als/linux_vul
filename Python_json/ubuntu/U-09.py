#!/usr/bin/python3
import os
import stat
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

# Ensure standard output encoding is set to UTF-8
if sys.version_info.major >= 3:
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except AttributeError:
        # This is for compatibility with Python versions before 3.7
        # In Python 3.7 and above, sys.stdout.reconfigure is available
        pass
        
def check_etc_hosts_permissions():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-09",
        "위험도": "상",
        "진단 항목": "/etc/hosts 파일 소유자 및 권한 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "/etc/hosts 파일의 소유자가 root이고, 권한이 600 이하인 경우"
    }

    hosts_file = '/etc/hosts'
    if os.path.exists(hosts_file):
        file_stat = os.stat(hosts_file)
        mode = oct(file_stat.st_mode)[-3:]
        owner_uid = file_stat.st_uid

        # Check if owner is root
        if owner_uid == 0:
            # Check file permissions
            if int(mode, 8) <= 0o600:
                results["진단 결과"] = "양호"
                results["현황"].append(f"/etc/hosts 파일의 소유자가 root이고, 권한이 {mode}입니다.")
            else:
                results["진단 결과"] = "취약"
                results["현황"].append(f"/etc/hosts 파일의 권한이 {mode}로 설정되어 있어 취약합니다.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("/etc/hosts 파일의 소유자가 root가 아닙니다.")
    else:
        results["진단 결과"] = "N/A"
        results["현황"].append("/etc/hosts 파일이 없습니다.")

    return results

def main():
    results = check_etc_hosts_permissions()
    print_as_md(results)

if __name__ == "__main__":
    main()
