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

def check_etc_passwd_permissions():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-07",
        "위험도": "상",
        "진단 항목": "/etc/passwd 파일 소유자 및 권한 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "/etc/passwd 파일의 소유자가 root이고, 권한이 644 이하인 경우"
    }

    passwd_file = '/etc/passwd'
    if os.path.exists(passwd_file):
        file_stat = os.stat(passwd_file)
        mode = oct(file_stat.st_mode)[-3:]
        owner_uid = file_stat.st_uid

        # Check if owner is root
        if owner_uid == 0:
            # Check file permissions
            if int(mode, 8) <= 0o644:
                results["진단 결과"] = "양호"
                results["현황"].append(f"/etc/passwd 파일의 소유자가 root이고, 권한이 {mode}입니다.")
            else:
                results["진단 결과"] = "취약"
                results["현황"].append(f"/etc/passwd 파일의 권한이 {mode}로 설정되어 있어 취약합니다.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("/etc/passwd 파일의 소유자가 root가 아닙니다.")
    else:
        results["진단 결과"] = "N/A"
        results["현황"].append("/etc/passwd 파일이 없습니다.")

    return results
    
def main():
    results = check_etc_passwd_permissions()
    # 결과를 콘솔에 출력할 때
    print_as_md(results)
    # 결과를 파일에 쓸 때
    with open('results.json', 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()
