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


def check_nfs_config_permissions():
    results = {
        "분류": "서비스 관리",
        "코드": "U-69",
        "위험도": "중",
        "진단 항목": "NFS 설정파일 접근권한",
        "진단 결과": "",  # 초기 진단 결과 설정하지 않음
        "현황": "",
        "대응방안": "NFS 설정파일의 소유자를 root으로 설정하고, 권한을 644 이하로 설정"
    }

    exports_file = '/etc/exports'
    if os.path.exists(exports_file):
        file_stat = os.stat(exports_file)
        mode = file_stat.st_mode
        owner_uid = file_stat.st_uid

        # Check if owner is root and file permissions are 644 or less
        permissions = stat.S_IMODE(mode)
        if owner_uid == 0 and permissions <= 0o644:
            results["진단 결과"] = "양호"
            results["현황"] = "NFS 접근제어 설정파일의 소유자가 root이고, 권한이 644 이하입니다."
        else:
            results["진단 결과"] = "취약"
            if owner_uid != 0:
                results["현황"] = "/etc/exports 파일의 소유자(owner)가 root가 아닙니다."
            if permissions > 0o644:
                results["현황"] += " /etc/exports 파일의 권한이 644보다 큽니다." if results["현황"] else "/etc/exports 파일의 권한이 644보다 큽니다."
    else:
        results["진단 결과"] = "N/A"
        results["현황"] = "/etc/exports 파일이 없습니다."

    return results

def main():
    nfs_config_permission_check_results = check_nfs_config_permissions()
    print_as_md(nfs_config_permission_check_results)

if __name__ == "__main__":
    main()
