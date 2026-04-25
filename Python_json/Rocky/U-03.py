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

import re

def check_account_lockout_threshold():
    results = {
        "분류": "계정 관리",
        "코드": "U-03",
        "위험도": "상",
        "진단 항목": "계정 잠금 임계값 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "계정 잠금 임계값을 10회 이하로 설정"
    }

    files_to_check = [
        "/etc/pam.d/system-auth",
        "/etc/pam.d/password-auth"
    ]
    deny_modules = ["pam_tally2.so", "pam_faillock.so"]

    appropriate_settings = 0
    inappropriate_settings = 0

    for file_path in files_to_check:
        file_checked = False
        if os.path.exists(file_path):
            with open(file_path, "r", encoding='utf-8') as file:
                for line in file:
                    line = line.strip()
                    if not line.startswith("#") and "deny" in line:
                        file_checked = True
                        for deny_module in deny_modules:
                            if deny_module in line:
                                deny_value_matches = re.findall(r'deny=\d+', line)
                                if deny_value_matches:
                                    deny_value = int(deny_value_matches[0].split('=')[1])
                                    if deny_value <= 10:
                                        appropriate_settings += 1
                                    else:
                                        inappropriate_settings += 1
                                        results["현황"].append(f"{file_path}에서 {deny_module} 모듈의 계정 잠금 임계값이 {deny_value}회로 설정되어 있습니다. 권장 값은 10회 이하입니다.")
        if not file_checked:
            results["현황"].append(f"{file_path}에서 관련 설정을 찾을 수 없습니다.")

    if appropriate_settings == 0:
        results["진단 결과"] = "취약"
        if inappropriate_settings == 0:
            # 설정 자체가 발견되지 않은 경우
            results["현황"].append("계정 잠금 임계값을 설정하는 파일에서 관련 설정을 찾을 수 없습니다.")
        else:
            # 부적절한 설정만 발견된 경우
            results["현황"].append("모든 검사된 파일에서 계정 잠금 임계값 설정이 적절하지 않습니다.")
    else:
        results["진단 결과"] = "양호"

    return results

def main():
    results = check_account_lockout_threshold()
    print_as_md(results)

if __name__ == "__main__":
    main()
