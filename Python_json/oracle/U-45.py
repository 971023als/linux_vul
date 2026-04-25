#!/usr/bin/python3
import os
import subprocess
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


def check_su_restriction():
    results = {
        "분류": "계정관리",
        "코드": "U-45",
        "위험도": "하",
        "진단 항목": "root 계정 su 제한",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "su 명령어 사용 특정 그룹 제한"
    }

    pam_su_path = "/etc/pam.d/su"
    if os.path.isfile(pam_su_path):
        with open(pam_su_path, 'r') as file:
            pam_contents = file.read()
            if 'pam_rootok.so' in pam_contents:
                if 'pam_wheel.so' not in pam_contents or 'auth required pam_wheel.so use_uid' not in pam_contents:
                    results["진단 결과"] = "취약"
                    results["현황"].append("/etc/pam.d/su 파일에 pam_wheel.so 모듈 설정이 적절히 구성되지 않았습니다.")
            else:
                results["진단 결과"] = "취약"
                results["현황"].append("/etc/pam.d/su 파일에서 pam_rootok.so 모듈이 누락되었습니다.")
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("/etc/pam.d/su 파일이 존재하지 않습니다.")

    return results

def main():
    su_restriction_check_results = check_su_restriction()
    print_as_md(su_restriction_check_results)

if __name__ == "__main__":
    main()
