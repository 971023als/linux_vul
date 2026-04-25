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

import pwd

def check_etc_services_permissions():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-12",
        "위험도": "상",
        "진단 항목": "/etc/services 파일 소유자 및 권한 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "/etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하인 경우"
    }

    services_file = '/etc/services'
    if os.path.exists(services_file):
        file_stat = os.stat(services_file)
        mode = oct(file_stat.st_mode)[-3:]
        owner_uid = file_stat.st_uid
        owner_name = pwd.getpwuid(owner_uid).pw_name

        if owner_name in ['root', 'bin', 'sys'] and int(mode, 8) <= 0o644:
            results["진단 결과"] = "양호"
            results["현황"].append(f"{services_file} 파일의 소유자가 {owner_name}이고, 권한이 {mode}입니다.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append(f"{services_file} 파일의 소유자나 권한이 기준에 부합하지 않습니다.")
    else:
        results["진단 결과"] = "N/A"
        results["현황"].append(f"{services_file} 파일이 없습니다.")

    return results

def main():
    results = check_etc_services_permissions()
    print_as_md(results)

if __name__ == "__main__":
    main()
