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

import glob

def get_umask_values_from_file(file_path):
    """Extracts and returns umask values found in the given file."""
    umask_values = []
    with open(file_path, 'r') as file:
        for line in file:
            if 'umask' in line and not line.strip().startswith('#'):
                parts = line.split('umask')
                if len(parts) > 1:
                    value_part = parts[1].split()
                    value = value_part[0].split('=')[-1] if '=' in value_part[0] else value_part[0]
                    umask_values.append(value.strip('`'))
    return umask_values

def check_umask_settings():
    results = {
        "분류": "파일 및 디렉토리 관리",
        "코드": "U-56",
        "위험도": "중",
        "진단 항목": "UMASK 설정 관리",
        "진단 결과": "양호",
        "현황": [],
        "대응방안": "UMASK 값이 022 이상으로 설정"
    }

    files_to_check = [
        "/etc/profile", "/etc/bash.bashrc", "/etc/csh.login", "/etc/csh.cshrc",
        *glob.glob("/home/*/.profile"), *glob.glob("/home/*/.bashrc"),
        *glob.glob("/home/*/.cshrc"), *glob.glob("/home/*/.login")
    ]

    checked_files = 0
    for file_path in files_to_check:
        if os.path.isfile(file_path):
            checked_files += 1
            umask_values = get_umask_values_from_file(file_path)
            for value in umask_values:
                if int(value, 8) < int('022', 8):
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{file_path} 파일에서 UMASK 값 ({value})이 022 이상으로 설정되지 않았습니다.")
    if results["진단 결과"] == "양호" and checked_files > 0:
        results["현황"].append("모든 검사된 파일에서 UMASK 값이 022 이상으로 적절히 설정되었습니다.")

    if checked_files == 0:
        results["현황"].append("검사할 파일이 없습니다.")

    return results

def main():
    umask_settings_check_results = check_umask_settings()
    print_as_md(umask_settings_check_results)

if __name__ == "__main__":
    main()
