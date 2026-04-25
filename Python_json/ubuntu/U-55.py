#!/usr/bin/python3
import os
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

import stat

def check_hosts_lpd_file():
    results = {
        "분류": "파일 및 디렉토리 관리",
        "코드": "U-55",
        "위험도": "하",
        "진단 항목": "hosts.lpd 파일 소유자 및 권한 설정",
        "진단 결과": "양호",  # Initially assume the result is "Good"
        "현황": [],
        "대응방안": "hosts.lpd 파일이 없거나, root 소유 및 권한 600 설정"
    }

    hosts_lpd_path = "/etc/hosts.lpd"
    if os.path.exists(hosts_lpd_path):  # Check if the file exists
        file_stat = os.stat(hosts_lpd_path)
        file_mode = stat.S_IMODE(file_stat.st_mode)
        file_owner = file_stat.st_uid

        if file_owner != 0 or file_mode != 0o600:  # If not owned by root or permissions are not 600
            results["진단 결과"] = "취약"
            owner_status = "root 소유가 아님" if file_owner != 0 else "소유자 상태는 양호함"
            permission_status = "권한이 600이 아님" if file_mode != 0o600 else "권한 상태는 양호함"
            results["현황"].append(f"{hosts_lpd_path} 파일 상태: {owner_status}, {permission_status}.")
    else:
        # If the file does not exist, it's considered Good, but let's log it for transparency.
        results["현황"].append(f"{hosts_lpd_path} 파일이 존재하지 않으므로 검사 대상이 아닙니다.")

    return results

def main():
    hosts_lpd_file_check_results = check_hosts_lpd_file()
    print_as_md(hosts_lpd_file_check_results)

if __name__ == "__main__":
    main()
